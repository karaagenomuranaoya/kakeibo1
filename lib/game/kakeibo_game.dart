import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

// 攻撃のスタイル詳細を定義するクラス
class AttackStyle {
  final Color textColor;
  final Color coinColor;
  final double textScale;
  final int coinCount;
  final double shakeIntensity;
  final String? extraText; // "NICE!", "GODLIKE!" などの追加テキスト
  final Color? flashColor; // フラッシュの色（nullならなし）

  AttackStyle({
    required this.textColor,
    required this.coinColor,
    required this.textScale,
    required this.coinCount,
    required this.shakeIntensity,
    this.extraText,
    this.flashColor,
  });

  // 金額からスタイルを生成するファクトリー
  factory AttackStyle.fromAmount(int amount) {
    if (amount >= 30000) {
      return AttackStyle(
        textColor: const Color(0xFF00FFFF), // Cyan Neon
        coinColor: Colors.white,
        textScale: 2.5,
        coinCount: 200,
        shakeIntensity: 50.0,
        extraText: "GODLIKE!!!",
        flashColor: Colors.black, // 暗転演出
      );
    } else if (amount >= 20000) {
      return AttackStyle(
        textColor: const Color(0xFFFF00FF), // Magenta Neon
        coinColor: Colors.cyanAccent,
        textScale: 2.2,
        coinCount: 150,
        shakeIntensity: 30.0,
        extraText: "MYTHICAL!!",
        flashColor: Colors.purpleAccent,
      );
    } else if (amount >= 10000) {
      return AttackStyle(
        textColor: const Color(0xFFFFD700), // Gold
        coinColor: const Color(0xFFFFD700),
        textScale: 2.0,
        coinCount: 100,
        shakeIntensity: 20.0,
        extraText: "LEGENDARY!",
        flashColor: Colors.white,
      );
    } else if (amount >= 9000) {
      return AttackStyle(
        textColor: Colors.deepPurpleAccent,
        coinColor: Colors.purple.shade200,
        textScale: 1.9,
        coinCount: 45,
        shakeIntensity: 15.0,
        extraText: "IMPOSSIBLE!",
      );
    } else if (amount >= 8000) {
      return AttackStyle(
        textColor: Colors.purple,
        coinColor: Colors.purple.shade100,
        textScale: 1.8,
        coinCount: 40,
        shakeIntensity: 13.0,
        extraText: "UNREAL!!",
      );
    } else if (amount >= 7000) {
      return AttackStyle(
        textColor: Colors.deepOrangeAccent,
        coinColor: Colors.deepOrange.shade200,
        textScale: 1.7,
        coinCount: 35,
        shakeIntensity: 11.0,
        extraText: "MAGNIFICENT",
      );
    } else if (amount >= 6000) {
      return AttackStyle(
        textColor: Colors.redAccent,
        coinColor: Colors.red.shade200,
        textScale: 1.6,
        coinCount: 30,
        shakeIntensity: 10.0,
        extraText: "FANTASTIC!",
        flashColor: Colors.red.withOpacity(0.3),
      );
    } else if (amount >= 5000) {
      return AttackStyle(
        textColor: Colors.red,
        coinColor: Colors.red.shade100,
        textScale: 1.5,
        coinCount: 25,
        shakeIntensity: 9.0,
        extraText: "AMAZING!",
      );
    } else if (amount >= 4000) {
      return AttackStyle(
        textColor: Colors.orangeAccent,
        coinColor: Colors.orange.shade200,
        textScale: 1.4,
        coinCount: 20,
        shakeIntensity: 8.0,
        extraText: "EXCELLENT!",
      );
    } else if (amount >= 3000) {
      return AttackStyle(
        textColor: Colors.orange,
        coinColor: Colors.orange.shade100,
        textScale: 1.3,
        coinCount: 18,
        shakeIntensity: 7.0,
        extraText: "SUPER!",
      );
    } else if (amount >= 2000) {
      return AttackStyle(
        textColor: Colors.amber,
        coinColor: Colors.amber.shade200,
        textScale: 1.2,
        coinCount: 15,
        shakeIntensity: 6.0,
        extraText: "GREAT!",
      );
    } else if (amount >= 1000) {
      return AttackStyle(
        textColor: Colors.yellow,
        coinColor: Colors.yellow.shade100,
        textScale: 1.1,
        coinCount: 12,
        shakeIntensity: 5.0,
        extraText: "GOOD!",
      );
    } else if (amount >= 100) {
      return AttackStyle(
        textColor: Colors.lightGreenAccent,
        coinColor: Colors.yellow.shade50,
        textScale: 1.0,
        coinCount: 8,
        shakeIntensity: 2.0,
        extraText: null,
      );
    } else {
      // 100円未満
      return AttackStyle(
        textColor: Colors.white,
        coinColor: Colors.grey.shade300,
        textScale: 0.8,
        coinCount: 3,
        shakeIntensity: 1.0,
        extraText: null,
      );
    }
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

  void triggerAttack(int amount, String categoryLabel) {
    // スタイル生成
    final style = AttackStyle.fromAmount(amount);

    // 1. ダメージテキスト
    add(DamageTextComponent(amount, style, size));

    // 2. フラッシュ演出
    if (style.flashColor != null) {
      add(ScreenFlashComponent(size, color: style.flashColor!));
    }

    // 3. 追加テキスト（GOOD!とか）
    if (style.extraText != null) {
      add(ExtraTextComponent(style.extraText!, style, size));
    }

    // 4. コインと絵文字
    for (int i = 0; i < style.coinCount; i++) {
      if (_rnd.nextDouble() < 0.2) {
        add(EmojiComponent(size, categoryLabel));
      } else {
        add(CoinComponent(size, style));
      }
    }

    // 5. 画面シェイク
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

// 画面フラッシュ用
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
    if (opacity <= 0) {
      removeFromParent();
    }
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
    // サイズも少し変化させる
    radius = 5.0 + (style.textScale * 2);

    position = Vector2(screenSize.x / 2, screenSize.y / 2 + 50);

    double angle = (Random().nextDouble() * pi) + pi;
    // 速度も金額に応じて速く
    double speedBase = 200 * style.textScale;
    double speed = Random().nextDouble() * speedBase + 200;

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
    else if (category.contains('交際'))
      emoji = '🍻';
    else if (category.contains('趣味'))
      emoji = '🎮';
    else if (category.contains('交通'))
      emoji = '🚃';
    else if (category.contains('本') || category.contains('教養'))
      emoji = '📚';
    else if (category.contains('服') || category.contains('美容'))
      emoji = '👗';
    else if (category.contains('家賃') || category.contains('住'))
      emoji = '🏠';

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
  final int amount;
  final AttackStyle style;
  final Vector2 screenSize;

  DamageTextComponent(this.amount, this.style, this.screenSize) : super() {
    double baseSize = 40.0;

    text = '¥ $amount';
    textRenderer = TextPaint(
      style: TextStyle(
        fontSize: baseSize * style.textScale,
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

    // アニメーション
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

// 追加テキスト（GOOD!とか）用のコンポーネント
class ExtraTextComponent extends TextComponent with HasGameRef {
  final AttackStyle style;

  ExtraTextComponent(String text, this.style, Vector2 screenSize) : super() {
    this.text = text;
    textRenderer = TextPaint(
      style: TextStyle(
        fontSize: 32 * style.textScale,
        fontWeight: FontWeight.bold,
        color: Colors.white, // 白文字
        letterSpacing: 2,
        shadows: [
          Shadow(
            color: style.textColor, // 影の色を金額カラーに合わせる
            blurRadius: 10,
            offset: const Offset(3, 3),
          ),
        ],
      ),
    );
    // 画面上部に配置
    position = Vector2(screenSize.x / 2 - (size.x / 2), 120);
  }

  @override
  Future<void> onLoad() async {
    // ビヨンビヨンさせる
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
