import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

// 攻撃スタイル (スキンIDを受け取れるように拡張)
class AttackStyle {
  final Color textColor;
  final Color coinColor;
  final double textScale;
  final int coinCount;
  final double shakeIntensity;
  final String? extraText;
  final Color? flashColor;

  // ★追加
  final String? skinId;

  AttackStyle({
    required this.textColor,
    required this.coinColor,
    required this.textScale,
    required this.coinCount,
    required this.shakeIntensity,
    this.extraText,
    this.flashColor,
    this.skinId,
  });

  factory AttackStyle.fromAmount(int amount, String? skinId) {
    // 既存の分岐ロジック (省略せず記述)
    AttackStyle base;
    if (amount >= 30000) {
      base = AttackStyle(
        textColor: const Color(0xFF00FFFF),
        coinColor: Colors.white,
        textScale: 2.5,
        coinCount: 200,
        shakeIntensity: 50.0,
        extraText: "GODLIKE!!!",
        flashColor: Colors.black,
        skinId: skinId, // 継承
      );
    } else if (amount >= 10000) {
      base = AttackStyle(
        textColor: const Color(0xFFFFD700),
        coinColor: const Color(0xFFFFD700),
        textScale: 2.0,
        coinCount: 100,
        shakeIntensity: 20.0,
        extraText: "LEGENDARY!",
        flashColor: Colors.white,
        skinId: skinId,
      );
    } else if (amount >= 5000) {
      base = AttackStyle(
        textColor: Colors.red,
        coinColor: Colors.red.shade100,
        textScale: 1.5,
        coinCount: 25,
        shakeIntensity: 9.0,
        extraText: "AMAZING!",
        skinId: skinId,
      );
    } else if (amount >= 1000) {
      base = AttackStyle(
        textColor: Colors.yellow,
        coinColor: Colors.yellow.shade100,
        textScale: 1.1,
        coinCount: 12,
        shakeIntensity: 5.0,
        extraText: "GOOD!",
        skinId: skinId,
      );
    } else {
      base = AttackStyle(
        textColor: Colors.white,
        coinColor: Colors.grey.shade300,
        textScale: 0.8,
        coinCount: 3,
        shakeIntensity: 1.0,
        skinId: skinId,
      );
    }
    return base;
  }
}

class KakeiboGame extends FlameGame {
  final Random _rnd = Random();

  @override
  Color backgroundColor() => const Color(0xFF1A1A2E);

  @override
  Future<void> onLoad() async {
    for (int i = 0; i < 50; i++) {
      add(StarComponent(size));
    }
  }

  // triggerAttackに skinId 引数を追加
  void triggerAttack(int amount, String categoryLabel, String? skinId) {
    final style = AttackStyle.fromAmount(amount, skinId);

    add(DamageTextComponent(amount, style, size));

    if (style.flashColor != null) {
      add(ScreenFlashComponent(size, color: style.flashColor!));
    }

    if (style.extraText != null) {
      add(ExtraTextComponent(style.extraText!, style, size));
    }

    for (int i = 0; i < style.coinCount; i++) {
      if (_rnd.nextDouble() < 0.2) {
        add(EmojiComponent(size, categoryLabel));
      } else {
        // ★スキンIDに応じてコンポーネントを切り替え
        if (skinId == 'matrix') {
          add(MatrixCodeComponent(size, style));
        } else if (skinId == 'gem') {
          add(GemComponent(size, style));
        } else {
          add(CoinComponent(size, style));
        }
      }
    }

    camera.viewfinder.add(
      SequenceEffect([
        MoveEffect.by(
          Vector2(style.shakeIntensity, 0),
          EffectController(duration: 0.05, alternate: true),
        ),
        MoveEffect.by(
          Vector2(-style.shakeIntensity, style.shakeIntensity),
          EffectController(duration: 0.05, alternate: true),
        ),
        MoveEffect.by(
          Vector2(style.shakeIntensity, style.shakeIntensity),
          EffectController(duration: 0.05, alternate: true),
        ),
        MoveEffect.by(
          Vector2(0, -style.shakeIntensity),
          EffectController(duration: 0.05, alternate: true),
        ),
      ]),
    );
  }
}

// ★新規スキン: マトリックスコード（緑の数字）
class MatrixCodeComponent extends TextComponent with HasGameRef {
  Vector2 velocity = Vector2.zero();
  final Vector2 gravity = Vector2(0, 800);

  MatrixCodeComponent(Vector2 screenSize, AttackStyle style) : super() {
    // ランダムな半角数字/文字
    final chars = ['0', '1', 'A', 'Z', 'X', '9'];
    text = chars[Random().nextInt(chars.length)];

    textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.greenAccent,
        fontSize: 16 + (style.textScale * 4),
        fontFamily: 'Courier', // 等幅フォントっぽく
        shadows: [const Shadow(color: Colors.green, blurRadius: 5)],
      ),
    );

    position = Vector2(screenSize.x / 2, screenSize.y / 2 + 50);

    double angle = (Random().nextDouble() * pi) + pi;
    double speed = Random().nextDouble() * 300 + 200;
    velocity = Vector2(cos(angle) * speed, sin(angle) * speed);
  }

  @override
  void update(double dt) {
    super.update(dt);
    velocity += gravity * dt;
    position += velocity * dt;
    if (position.y > gameRef.size.y) removeFromParent();
  }
}

// ★新規スキン: 宝石（菱形）
class GemComponent extends PositionComponent with HasGameRef {
  Vector2 velocity = Vector2.zero();
  final Vector2 gravity = Vector2(0, 800);
  final Paint _paint;

  GemComponent(Vector2 screenSize, AttackStyle style)
    : _paint = Paint()..color = Colors.redAccent.withOpacity(0.8),
      super() {
    size = Vector2.all(10 + (style.textScale * 5));
    position = Vector2(screenSize.x / 2, screenSize.y / 2 + 50);

    double angle = (Random().nextDouble() * pi) + pi;
    double speed = Random().nextDouble() * 300 + 200;
    velocity = Vector2(cos(angle) * speed, sin(angle) * speed);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // 菱形を描く
    final path = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(size.x, size.y / 2)
      ..lineTo(size.x / 2, size.y)
      ..lineTo(0, size.y / 2)
      ..close();
    canvas.drawPath(path, _paint);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white
        ..strokeWidth = 1,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    velocity += gravity * dt;
    position += velocity * dt;
    angle += dt * 5; // 回転
    if (position.y > gameRef.size.y) removeFromParent();
  }
}

// ... 以下、既存コンポーネント (ScreenFlash, Star, Coin, Emoji, Damage, Extra) はそのまま ...
// (長いので省略しますが、前回のコードにあるクラス定義はそのまま使ってください)
class ScreenFlashComponent extends PositionComponent {
  double opacity = 0.8;
  final Color color;
  ScreenFlashComponent(Vector2 screenSize, {required this.color}) : super() {
    size = screenSize;
    position = Vector2.zero();
    priority = 100;
  }
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(size.toRect(), Paint()..color = color.withOpacity(opacity));
  }

  @override
  void update(double dt) {
    super.update(dt);
    opacity -= dt * 5.0;
    if (opacity <= 0) removeFromParent();
  }
}

class StarComponent extends CircleComponent {
  StarComponent(Vector2 screenSize) : super(radius: 0) {
    double r = Random().nextDouble() * 2 + 1;
    radius = r;
    paint = Paint()
      ..color = Colors.white.withOpacity(Random().nextDouble() * 0.5 + 0.1);
    position = Vector2(
      Random().nextDouble() * screenSize.x,
      Random().nextDouble() * screenSize.y,
    );
  }
}

class CoinComponent extends CircleComponent with HasGameRef {
  Vector2 velocity = Vector2.zero();
  final Vector2 gravity = Vector2(0, 800);
  CoinComponent(Vector2 screenSize, AttackStyle style) : super(radius: 8) {
    paint = Paint()..color = style.coinColor;
    radius = 5.0 + (style.textScale * 2);
    position = Vector2(screenSize.x / 2, screenSize.y / 2 + 50);
    double angle = (Random().nextDouble() * pi) + pi;
    double speed = Random().nextDouble() * 200 * style.textScale + 200;
    velocity = Vector2(cos(angle) * speed, sin(angle) * speed);
  }
  @override
  void update(double dt) {
    super.update(dt);
    velocity += gravity * dt;
    position += velocity * dt;
    if (position.y > gameRef.size.y) removeFromParent();
  }
}

class EmojiComponent extends TextComponent with HasGameRef {
  Vector2 velocity = Vector2.zero();
  final Vector2 gravity = Vector2(0, 500);
  EmojiComponent(Vector2 screenSize, String category) : super() {
    String emoji = '💰';
    if (category.contains('食'))
      emoji = '🍔';
    else if (category.contains('日用'))
      emoji = '🧻';
    text = emoji;
    textRenderer = TextPaint(style: const TextStyle(fontSize: 24));
    position = Vector2(screenSize.x / 2, screenSize.y / 2 + 50);
    double angle = (Random().nextDouble() * pi) + pi;
    double speed = Random().nextDouble() * 400 + 100;
    velocity = Vector2(cos(angle) * speed, sin(angle) * speed);
  }
  @override
  void update(double dt) {
    super.update(dt);
    velocity += gravity * dt;
    position += velocity * dt;
    angle += dt * 5;
    if (position.y > gameRef.size.y) removeFromParent();
  }
}

class DamageTextComponent extends TextComponent {
  final Vector2 screenSize;
  DamageTextComponent(int amount, AttackStyle style, this.screenSize)
    : super() {
    text = '¥ $amount';
    textRenderer = TextPaint(
      style: TextStyle(
        fontSize: 40.0 * style.textScale,
        fontWeight: FontWeight.w900,
        color: style.textColor,
        shadows: [
          Shadow(
            blurRadius: 10 * style.textScale,
            color: style.coinColor.withOpacity(0.8),
            offset: Offset(2 * style.textScale, 2 * style.textScale),
          ),
        ],
      ),
    );
  }
  @override
  Future<void> onLoad() async {
    position = Vector2(screenSize.x / 2 - size.x / 2, screenSize.y / 2 - 100);
    add(
      ScaleEffect.to(
        Vector2.all(1.5),
        EffectController(duration: 0.1, curve: Curves.easeOut),
      ),
    );
    add(
      MoveEffect.by(
        Vector2(0, -150),
        EffectController(duration: 0.8, curve: Curves.easeOut),
        onComplete: () => removeFromParent(),
      ),
    );
  }
}

class ExtraTextComponent extends TextComponent with HasGameRef {
  ExtraTextComponent(String text, AttackStyle style, Vector2 screenSize)
    : super() {
    this.text = text;
    textRenderer = TextPaint(
      style: TextStyle(
        fontSize: 32 * style.textScale,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [
          Shadow(
            color: style.textColor,
            blurRadius: 10,
            offset: const Offset(3, 3),
          ),
        ],
      ),
    );
    position = Vector2(screenSize.x / 2 - (size.x / 2), 120);
  }
  @override
  Future<void> onLoad() async {
    add(
      ScaleEffect.to(
        Vector2.all(1.2),
        EffectController(
          duration: 0.2,
          alternate: true,
          repeatCount: 3,
          curve: Curves.elasticOut,
        ),
        onComplete: () => removeFromParent(),
      ),
    );
  }
}
