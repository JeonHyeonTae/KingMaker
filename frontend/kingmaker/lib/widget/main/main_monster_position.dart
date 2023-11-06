
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kingmaker/widget/main/main_game.dart';
import 'package:kingmaker/widget/main/main_monster.dart';
enum MonsterDirection {
  LEFT,
  RIGHT,
}
class MonsterPosition extends PositionComponent {
  final MyGame game;
  final Random _random = Random();
  final List<String> categorytList =["slime", "skeleton", "goblin", "nutty", "panda", "bear"];
  late int categoryId;
  MonsterDirection currentDirection = MonsterDirection.RIGHT;
  Vector2 velocity = Vector2.zero();
  Map<String, String> monsterInfo;
  MonsterPosition(this.game, this.monsterInfo) {
    setRandomVelocity();
    this.size = Vector2(144,144);
  }
  late Monster monster;
  late MonsterText monsterText;

  double _elapsedTime = 0.0;
  double _delay = 2.0; // 2초의 지연

  @override
  void onLoad() {
    super.onLoad();
    position = position = getRandomPositionOutsideRestrictedArea();
    categoryId = int.tryParse(monsterInfo['category_id'] ?? '') ?? 0;
    monster = Monster(this.game, monsterInfo);
    monsterText = MonsterText(monsterInfo);

    add(monster);
    // add(monsterText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsedTime += dt;
    position += velocity * dt;  // MonsterPosition의 위치를 업데이트
    // print('x: ${position.x} y: ${position.y}');

    // 몬스터가 제한 구역에 진입하려는지 확인
    if (isEnteringRestrictedArea(position)) {
      // 제한 구역에서 멀어지도록 속도 조정
      if (position.x >= 80 && position.x <= 500) {
        velocity.x = position.x < (80 + 500) / 2 ? -velocity.x.abs() : velocity.x.abs();
      }
      if (position.y >= -40 && position.y <= 300) {
        velocity.y = position.y < (-40 + 300) / 2 ? -velocity.y.abs() : velocity.y.abs();
      }
    }

    if (velocity.x > 0 && currentDirection != MonsterDirection.RIGHT) {
      currentDirection = MonsterDirection.RIGHT;
      monster.changeAnimation('${categorytList[categoryId-1]}_right.png');

    } else if (velocity.x < 0 && currentDirection != MonsterDirection.LEFT) {
      currentDirection = MonsterDirection.LEFT;
      monster.changeAnimation('${categorytList[categoryId-1]}_left.png');
    }
    if (monster != null && monsterText != null) {
      // monster.position = position;
      monsterText.position = Vector2(-14, 10);// 원하는 오프셋으로 변경하세요.
    }

    //경계값에 다달았을 때
    if (position.x <= -100 || position.x >= 1000 - size.x) {
      // 이미 경계를 넘어갔는지 확인하고, 그렇다면 경계 내부로 위치를 재조정
      position.x = max(-100, min(position.x, 1000 - size.x));
      setRandomVelocity();
    }
  //경계값에 다달았을 때
    // Y축 경계 확인
    if (position.y <= 0 || position.y >= 1024 - size.y) {
      // 이미 경계를 넘어갔는지 확인하고, 그렇다면 경계 내부로 위치를 재조정
      position.y = max(0, min(position.y, 1024 - size.y));
      setRandomVelocity();
    }

    if (_elapsedTime >= _delay) {
      // 지연 후에 실행할 코드
      _elapsedTime = 2; // 지연 시간을 재설정
    }
  }
  void setRandomVelocity() {
    double speed = 100.0;
    double direction = _random.nextDouble() * 2 * pi;
    velocity = Vector2(cos(direction) * speed, sin(direction) * speed);
  }


  bool isEnteringRestrictedArea(Vector2 position) {
    // 제한된 사각형 영역 정의
    final restrictedTopLeft = Vector2(80, -40);
    final restrictedBottomRight = Vector2(500, 300);

    // 위치가 제한된 영역 내에 있는지 확인
    return position.x >= restrictedTopLeft.x &&
        position.x <= restrictedBottomRight.x &&
        position.y >= restrictedTopLeft.y &&
        position.y <= restrictedBottomRight.y;
  }

  Vector2 getRandomPositionOutsideRestrictedArea() {
    Vector2 initialPosition;
    do {
      initialPosition = Vector2(
        _random.nextDouble() * (1024 - size.x),
        _random.nextDouble() * (1024 - size.y),
      );
    } while (isWithinRestrictedArea(initialPosition));

    return initialPosition;
  }

  bool isWithinRestrictedArea(Vector2 position) {
    // 제한된 사각형 영역의 위치 범위를 정의합니다.
    final double restrictedLeftX = 80;
    final double restrictedRightX = 500;
    final double restrictedTopY = -40;
    final double restrictedBottomY = 300;

    // position이 제한된 사각형 영역 내에 있는지 검사합니다.
    return position.x > restrictedLeftX && position.x < restrictedRightX
        && position.y > restrictedTopY && position.y < restrictedBottomY;
  }


}

class MonsterText extends TextComponent{
  final Map<String, String> monsterInfo;
  late TextPainter textPainter;

  MonsterText(this.monsterInfo) {
    textPainter = TextPainter(textDirection: TextDirection.ltr);
    final textSpan = TextSpan(
      text: monsterInfo['todo_nm'],
      style: TextStyle(color: Colors.black, fontSize: 16.0),
    );
    textPainter.text = textSpan;
    textPainter.layout();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    textPainter.paint(canvas, position.toOffset());
  }
}