import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { decode, verify } from "jws";
import axios from "axios";

/** Public webapp key. Required by `signInWithCustomToken` REST API.  */
const WEBAPP_APIKEY = "AIzaSyBOHR4kL1aHMVQBjXTW5Lq8piFrJLGYPeI";

/** Schema for Firestore `/devices/{deviceId}` documents. */
interface DeviceData {
  nonce?: number;
  publicKey: string;
  uid: string;
  getIdTokenTime?: admin.firestore.Timestamp;
}

interface Device {
  id: string;
  data: DeviceData;
}

/** Response body of `signInWithCustomToken` REST API. */
interface SignInWithCustomTokenResponse {
  idToken: string;
  refreshToken: string;
  expiresIn: number;
}

/** Looks up and returns a device by its id. */
async function getDevice(id: string): Promise<Device | null> {
  const docSnapshot = await deviceCollection.doc(id).get();
  return docSnapshot.exists
    ? { id: docSnapshot.id, data: docSnapshot.data()! }
    : null;
}

/** Prints a decoded representation, alongside the JWT to the console. */
function printJWT(message: string, token: string) {
    const decoded = decode(token);
    if (decoded) {
  const { header, payload } = decoded;
  console.log(message, header, payload, token);
}
}

/** Generates, persists and returns a unique (per device) number. */
async function getNextNonce(device: Device) {
  const nonce = (device.data.nonce || 0) + 1;
  await deviceCollection.doc(device.id).update({
    nonce,
    getIdTokenTime: admin.firestore.FieldValue.serverTimestamp(),
  });
  return nonce;
}

/**
 * Reformats the base64 encoded key.
 * When manually copying the key, some whitespace is changed, making the key non-compliant with the spec.
 */
function normalizePublicKey(pk: string) {
  return (
    "-----BEGIN PUBLIC KEY-----\n" +
    pk.replace(/\\s|-----(BEGIN|END) PUBLIC KEY-----/g, "") +
    "\n-----END PUBLIC KEY-----\n"
  );
}

admin.initializeApp();

const deviceCollection = admin
  .firestore()
  .collection("devices") as admin.firestore.CollectionReference<DeviceData>;

/** Generates and returns new Firebase id token for the provided device token. */
exports.getIdToken = functions.https.onRequest(async (req, res) => {
  const deviceToken = req.body;
  printJWT("Device token: ", deviceToken);
  const decoded = decode(deviceToken);
  if (decoded) {
  const { header, payload } = decoded; 
  const device = header.kid && (await getDevice(header.kid));
  if (!device) {
    res.status(401).send({
      errorCode: 1,
      message: "Unknown device!",
    });
    return;
  }
  console.log("Device found: ", device.id, device.data);

  // ATECCx08 crypto chips only support ES256.
  const alg = "ES256";
  // Verify the validity of device-generated JWT.
  const verifyResult = verify(
    deviceToken,
    alg,
    normalizePublicKey(device.data.publicKey)
  );
  if (!verifyResult || header.alg !== alg) {
    res.status(401).send({
      errorCode: 4,
      message: "Invalid JWT!",
    });
    return;
  }

  const payloadNonce = Number(JSON.parse(payload).nonce);
  let nonce = device.data.nonce || (await getNextNonce(device));
  if (payloadNonce !== nonce) {
    // Invalid nonce.
    // Not necessarily a replay attack, the device might just be out of sync due to a network error.
    res.status(401).send({
      errorCode: 3,
      message: "Invalid nonce!",
      nonce,
    });
    return;
  }

  if (!device.data.uid) {
    // This device is not associated with a user account.
    res.status(401).send({
      errorCode: 2,
      message: "Unclaimed device!",
    });
    return;
  }

  const customToken = await admin
    .auth()
    .createCustomToken(device.data.uid, { deviceId: device.id });
  printJWT("Custom token: ", customToken);

  const idTokenResponse = await axios.post<SignInWithCustomTokenResponse>(
    "https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=" +
      WEBAPP_APIKEY,
    { token: customToken, returnSecureToken: true }
  );
  const idToken = idTokenResponse.data.idToken;
  printJWT("Id token: ", idToken);

  res.send({
    nonce: await getNextNonce(device),
    idToken,
  });}
});