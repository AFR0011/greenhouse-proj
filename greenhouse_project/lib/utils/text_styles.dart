/// TextStyles to be used throughout the applications
library;

import "package:flutter/material.dart";

const TextStyle headingTextStyle = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.bold,
);

const TextStyle subheadingTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w500,
);

const TextStyle bodyTextStyle = TextStyle(
  overflow: TextOverflow.ellipsis,
  fontSize: 16,
);

const TextStyle buttonTextStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const TextStyle lightButtonTextStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);
