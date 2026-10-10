import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flashcards/data/repositories/utils/user_claims.dart';
import 'package:flashcards/ui/pages/paywall/dev_paywall_page.dart';

import '../main_common.dart';
import '../ui/pages/paywall/prod_paywall_page.dart';

T? valueIfChanged<T>(T original, T updated) {
  return original != updated ? updated : null;
}

List<T>? listIfChanged<T>(List<T> original, List<T> updated) {
  final originalSet = original.toSet();
  final updatedSet = updated.toSet();
  return originalSet.length != updatedSet.length ||
          !originalSet.containsAll(updatedSet)
      ? updated
      : null;
}

String formatSmartDate(DateTime dateTime, {String locale = 'en'}) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays == 0) {
    return timeago.format(
      dateTime,
      locale: locale,
    ); // 3 hours ago, 1 minute ago, a moment ago...
  } else if (difference.inDays == 1) {
    return 'Yesterday at ${DateFormat('h:mm a').format(dateTime)}';
  } else if (difference.inDays < 30) {
    return timeago.format(dateTime, locale: locale); // 21 days ago
  } else {
    return DateFormat("MMM d, yyyy").format(dateTime); // May 24, 2025
  }
}

String formatInterval(
  DateTime due,
  DateTime now, {
  bool enablePrinting = false,
}) {
  final duration = due.difference(now);
  if (enablePrinting) print("[DURATION] $duration");

  if (duration.inSeconds <= 0) return 'now';

  if (duration.inMinutes < 60) {
    final minutes =
        duration.inMinutes + (duration.inSeconds % 60 > -30 ? 1 : 0);
    if (enablePrinting) print("in minutes: $minutes");
    return '${minutes}m';
  }

  if (duration.inHours < 24) {
    final hours = duration.inHours + (duration.inMinutes % 60 > -30 ? 1 : 0);
    if (enablePrinting) print('in hours: $hours');
    return '${hours}h';
  }

  if (duration.inDays < 7) {
    final days = duration.inDays + (duration.inHours % 24 > -12 ? 1 : 0);
    if (enablePrinting) print('in days: $days');
    return '${days}d';
  }

  final weeks =
      (duration.inDays / 7).floor() + (duration.inDays % 7 >= 4 ? 1 : 0);
  if (enablePrinting) print('in weeks: $weeks');
  return '${weeks}w';
}

String redactClozeQuestion(String question) {
  final pattern = RegExp(r'\{[^}]*\}');
  return question.replaceAllMapped(pattern, (match) => '[...]');
}

String revealClozeQuestion(String question) {
  final pattern = RegExp(r'\{([^}]*)\}');
  return question.replaceAllMapped(pattern, (match) => match.group(1)!);
}

int calculateCardsPerSessionDifference({
  required int currentBatch,
  required int currentFlashcardIndex,
  required int currentCardsPerSession,
}) {
  return (currentBatch - 1) * currentCardsPerSession + currentFlashcardIndex;
}

List<T> updateOneElementWithEquals<T>(
  List<T> original,
  T element,
  bool Function(T, T) equals,
) {
  final updatedList = List<T>.from(original);
  int index = updatedList.indexWhere((el) => equals(el, element));
  if (index == -1) return original;
  updatedList[index] = element;
  return updatedList;
}

int getElementIndex<T>(List<T> original, T element) {
  return original.indexWhere((el) => el == element);
}

List<T> removeElementAt<T>(List<T> original, int index) {
  final updatedList = List<T>.from(original);
  updatedList.removeAt(index);
  return updatedList;
}

List<T> removeElement<T>(List<T> original, T element) {
  final updatedList = List<T>.from(original);
  updatedList.remove(element);
  return updatedList;
}

List<T> addElement<T>(List<T> original, T element) {
  final updatedList = List<T>.from(original);
  updatedList.add(element);
  return updatedList;
}

List<T> insertElement<T>(List<T> original, T element, int index) {
  final updatedList = List<T>.from(original);
  if (updatedList.isNotEmpty && updatedList[index] == element) {
    return updatedList;
  }
  updatedList.insert(index, element);
  return updatedList;
}

(int pageIndex, int itemIndex)? getElementIndexInPages<T>(
  List<List<T>> pages,
  bool Function(T element) matcher,
) {
  for (int i = 0; i < pages.length; i++) {
    final elementIndex = pages[i].indexWhere(matcher);
    if (elementIndex != -1) return (i, elementIndex);
  }
  return null;
}

List<List<T>> removeElementFromPagesAt<T>(
  List<List<T>> original,
  (int pageIndex, int elementIndex) indexes,
) {
  final pageIndex = indexes.$1;
  final elementIndex = indexes.$2;

  // deep copy of outer list
  final updatedList = List<List<T>>.from(original);

  // then we preform deep copy of inner list
  final updatedPage = List<T>.from(updatedList[pageIndex]);
  updatedPage.removeAt(elementIndex);
  updatedList[pageIndex] = updatedPage;

  return updatedList;
}

List<List<T>> removeElementFromPage<T>(
  List<List<T>> original,
  bool Function(T element) matcher,
) {
  final updatedList = List<List<T>>.from(original);
  for (int i = 0; i < updatedList.length; i++) {
    final page = updatedList[i];
    final index = page.indexWhere(matcher);
    if (index != -1) {
      final newPage = List<T>.from(page)..removeAt(index);
      updatedList[i] = newPage;
      break;
    }
  }
  return updatedList;
}

List<List<T>> updateElementInPage<T>(
  List<List<T>> original,
  bool Function(T element) matcher,
  T Function(T element) copyWith,
) {
  final updatedList = List<List<T>>.from(original);
  for (int i = 0; i < updatedList.length; i++) {
    final page = updatedList[i];
    final index = page.indexWhere(matcher);
    if (index != -1) {
      final newPage = List<T>.from(page);
      newPage[index] = copyWith(newPage[index]);
      updatedList[i] = newPage;
      break;
    }
  }
  return updatedList;
}

List<List<T>> insertElementIntoPage<T>(
  List<List<T>> original,
  T element,
  (int pageIndex, int elementIndex) indexes,
) {
  final pageIndex = indexes.$1;
  final elementIndex = indexes.$2;

  // deep copy of outer list
  final updatedList = List<List<T>>.from(original);

  // then we preform deep copy of inner list
  final updatedPage = List<T>.from(updatedList[pageIndex]);
  if (updatedPage.isNotEmpty && updatedPage.contains(element)) {
    return updatedList;
  }

  updatedPage.insert(elementIndex, element);
  updatedList[pageIndex] = updatedPage;

  return updatedList;
}

(int pageIndex, int elementIndex) getMatrixIndexFromFlatIndex(
  int flatIndex,
  int pageSize,
) {
  return (flatIndex ~/ pageSize, flatIndex % pageSize);
}

Map<K, V> updateMapEntry<K, V>(Map<K, V> original, K key, V value) {
  return Map<K, V>.from(original)..[key] = value;
}

Map<K, V> deleteMapEntry<K, V>(Map<K, V> original, K key) {
  return Map<K, V>.from(original)..remove(key);
}

bool shouldDeleteFlashcardSnapshot({
  required bool hasBookmark,
  required bool ignored,
}) {
  return !(hasBookmark || ignored);
}

Future<void> exportCollectionToJson({
  required String collectionPath,
  required String outputFilePath,
}) async {
  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore.collection(collectionPath).get();

  final Map<String, dynamic> data = {
    for (var doc in snapshot.docs) doc.id: doc.data(),
  };

  final file = File(outputFilePath);
  await file.writeAsString(jsonEncode(data));

  print('✅ Exported ${snapshot.docs.length} documents to $outputFilePath');
}

Future<bool> ensureCardsAccess(BuildContext context) async {
  var claims = await UserClaims.current();
  if (claims.hasCards) return true;

  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await user.getIdToken(true);
    claims = await UserClaims.current();
    if (claims.hasCards) return true;
  }

  final page = Flavor.isProd ? const ProdPaywallPage() : const DevPaywallPage();
  final unlocked = await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => page),
  );

  if (user != null) {
    await user.getIdToken(true);
  }
  return unlocked == true;
}

Future<bool> ensureOsceAccess(BuildContext context) async {
  var claims = await UserClaims.current();
  if (claims.hasOsce) return true;

  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await user.getIdToken(true);
    claims = await UserClaims.current();
    if (claims.hasOsce) return true;
  }

  final page = Flavor.isProd ? const ProdPaywallPage() : const DevPaywallPage();
  final unlocked = await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => page),
  );

  if (user != null) {
    await user.getIdToken(true);
  }
  return unlocked == true;
}
