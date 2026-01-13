import 'dart:math';
import '../models/familiar.dart';

class SkillResult {
  final double multiplier;
  final String? activationMessage;

  SkillResult(this.multiplier, this.activationMessage);
}

class FamiliarService {
  final Random _rnd = Random();

  SkillResult calculateSkillBonus(Familiar? buddy, int amount) {
    if (buddy == null) return SkillResult(1.0, null);

    double skillMultiplier = 1.0;
    String? activationText;
    final nowHour = DateTime.now().hour;
    final rndVal = _rnd.nextDouble();

    switch (buddy.skillType) {
      case SkillType.lowCostBonus:
        if (amount <= 1000) {
          skillMultiplier = 1.5;
          activationText = "MICRO SAVER ACTIVATED! (x1.5)";
        }
        break;
      case SkillType.nightBonus:
        if (nowHour >= 18 || nowHour < 6) {
          skillMultiplier = 1.5;
          activationText = "NIGHT WALKER ACTIVATED! (x1.5)";
        }
        break;
      case SkillType.randomCritical:
        if (buddy.id == 'crypto_dragon') {
          if (rndVal < 0.05) {
            skillMultiplier = 10.0;
            activationText = "TO THE MOON!!! (x10.0)";
          }
        } else if (buddy.id == 'cyber_wolf') {
          if (rndVal < 0.20) {
            skillMultiplier = 3.0;
            activationText = "CRITICAL FANG! (x3.0)";
          }
        } else {
          if (rndVal < 0.50) {
            skillMultiplier = 2.0;
            activationText = "LUCKY GLITCH! (x2.0)";
          }
        }
        break;
      case SkillType.passiveBoost:
        if (buddy.id == 'singularity_eye') {
          skillMultiplier = 3.0;
          activationText = "SINGULARITY POWER (x3.0)";
        } else if (buddy.id == 'code_spider') {
          skillMultiplier = 1.2;
          activationText = "WEB BOOST (x1.2)";
        } else {
          skillMultiplier = 1.1;
          activationText = "PASSIVE BOOST (x1.1)";
        }
        break;
      case SkillType.highRoller:
        if (amount >= 5000) {
          skillMultiplier = 2.5;
          activationText = "HIGH ROLLER! (x2.5)";
        }
        break;
      default:
        break;
    }

    return SkillResult(skillMultiplier, activationText);
  }
}
