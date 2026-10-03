# Patched firebase_auth_web 5.15.3

Copy of firebase_auth_web 5.15.3 with one fix in
`lib/src/interop/auth.dart` (`onWaitInitState`): an auth error while the
website starts no longer crashes with "Null check operator used on a null
value"; it is logged to the browser console and the app starts signed out.

The same bug is fixed upstream in firebase_auth_web 6.x. Remove this folder
and the `dependency_overrides` entry in pubspec.yaml when upgrading to
firebase_auth 6.
