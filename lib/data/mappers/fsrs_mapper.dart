import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashcards/domain/models/flashcards/card_info_item/card_info_item.dart';
import 'package:flashcards/utils/typedefs.dart';
import 'package:flashcards/utils/util_functions.dart';
import 'package:fsrs/fsrs.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart' as mat;

extension FsrsCardX on Card {
  JsonMap toJson() => {
    "due": Timestamp.fromDate(due),
    "stability": stability,
    "difficulty": difficulty,
    "elapsedDays": elapsedDays,
    "scheduledDays": scheduledDays,
    "reps": reps,
    "lapses": lapses,
    "state": state.toJson(),
    "lastReview": Timestamp.fromDate(lastReview),
  };

  static JsonMap? toJsonStatic(Card? card) {
    if (card == null) return null;

    return card.toJson();
  }

  static Card fromJson(JsonMap json) {
    //print('Raw JSON: $json');

    T requireField<T>(String key) {
      final value = json[key];
      if (value == null) {
        throw Exception("Missing required field '$key'");
      }
      if (value is! T) {
        throw Exception(
          "Field '$key' has invalid type: ${value.runtimeType}, expected $T",
        );
      }
      return value;
    }

    num requireNum(String key) {
      final value = json[key];
      if (value is num) return value;
      throw Exception("Field '$key' is not a number: $value");
    }

    final card =
        Card()
          ..due = requireField<Timestamp>('due').toDate()
          ..stability = requireNum('stability').toDouble()
          ..difficulty = requireNum('difficulty').toDouble()
          ..elapsedDays = requireField<int>('elapsedDays')
          ..scheduledDays = requireField<int>('scheduledDays')
          ..reps = requireField<int>('reps')
          ..lapses = requireField<int>('lapses')
          ..state = FsrsStateJsonX.fromJson(requireField<String>('state'))
          ..lastReview = requireField<Timestamp>('lastReview').toDate();
    //print(card);
    return card;
  }

  List<CardInfoItem> buildCardInfoItems() {
    if (state.isNewState) {
      return [
        CardInfoItem(
          icon: mat.Icons.info_outline,
          label: "ما تعاملت مع هذه البطاقة بعد",
          value: "",
          tooltip:
              "ما راجعت هذه البطاقة بعد، وستظهر لك في جلسة المذاكرة القادمة.",
        ),
      ];
    }

    return [
      CardInfoItem(
        label: "المراجعة القادمة",
        value: DateFormat("MMM d, HH:mm (y)").format(due),
        tooltip:
            "الموعد المجدول لمراجعة هذه البطاقة من جديد.",
        icon: mat.Icons.calendar_today,
      ),
      CardInfoItem(
        label: "آخر مراجعة",
        value: formatSmartDate(lastReview),
        tooltip: "آخر مرة راجعت فيها هذه البطاقة.",
        icon: mat.Icons.history,
      ),
      CardInfoItem(
        label: "عدد التكرارات",
        value: "$reps",
        tooltip: "كم مرة راجعت هذه البطاقة إجمالاً.",
        icon: mat.Icons.repeat,
      ),
      CardInfoItem(
        label: "مرات النسيان",
        value: "$lapses",
        tooltip:
            "كم مرة نسيت هذه البطاقة واحتجت تعيد تعلمها.",
        icon: mat.Icons.warning,
      ),
    ];
  }
}

extension StateX on State {
  bool get isNewState => this == State.newState;

  bool get isLearning => this == State.learning;

  bool get isRelearning => this == State.relearning;

  bool get isReview => this == State.review;
}

extension FsrsStateJsonX on State {
  String toJson() => name;

  static State fromJson(String name) {
    return State.values.firstWhere(
      (e) => e.name == name,
      orElse: () => State.newState,
    );
  }
}
