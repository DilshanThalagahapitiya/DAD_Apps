// ============================================================
// Localization extension — convenience accessor for AppLocalizations
// ============================================================
// Lets screens write `context.l10n.someKey` instead of the verbose
// `AppLocalizations.of(context)!.someKey`.
// ============================================================

import 'package:flutter/widgets.dart';
import 'package:dad_app/l10n/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
