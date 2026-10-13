/// The client ID of the "Web application" OAuth client in GYMTRX's Google
/// Cloud project (see README → Google Drive backup). Not a secret: Google
/// matches the app by its package name and signing key, and this only tells
/// Google Sign-In which project to use. Empty = Drive backup isn't set up.
const googleWebClientId = '';

bool get driveConfigured => googleWebClientId.isNotEmpty;
