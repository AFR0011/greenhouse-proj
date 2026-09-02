# Security history rewrite

This archived educational project previously committed revoked credentials for
Firebase administration, device Wi-Fi access, a Firebase test user, and a
client-side email integration. The current tree removes those credentials and
uses local or injected configuration examples instead.

The repository history was rewritten narrowly in a reviewed mirror and published
in place to remove the revoked values and service-account files while preserving
the original commit graph, authors, dates, and messages. Commit identifiers
necessarily change when a historical tree changes.

Old clones, forks, cached archives, and pull-request references may retain the
former objects. They must not be used as a source for credentials or republished.
This notice does not claim that public caches outside the repository owner's
control have been erased. GitHub Support cleanup of server-controlled historical
pull-request references and caches is pending.

The project remains archived. Employee provisioning is intentionally disabled
because the historical client-side password-delivery design is not suitable for
a live deployment. A future live successor would require a trusted backend and
an invitation or password-reset flow.
