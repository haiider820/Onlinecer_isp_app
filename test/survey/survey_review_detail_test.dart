import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/features/survey/presentation/connection_request_providers.dart';
import 'package:isp_onlinecer/features/survey/presentation/survey_request_detail_screen.dart';
import 'package:isp_onlinecer/models/connection_request.dart';

/// Survey-review detail screen: the Review button + the Inventory Approval
/// card, driven by `allowed_action` (never status).
///
/// The doc example payload: status `survey_review`, `allowed_action`
/// `review_survey`, one approved item request (Fiber Cable, 80m requested,
/// 80m approved).
Map<String, Object?> reviewDetailJson() => {
  'data': {
    'id': 'req-1',
    'request_number': 'CRQ-20261001-ABCD',
    'status': 'survey_review',
    'customer_name': 'Test Customer',
    'current_team': {
      'id': 'team_uuid',
      'name': 'Survey Team',
      'functional_team_type': 'survey',
    },
    'item_requests': [
      {
        'id': 'item_request_uuid',
        'status': 'approved',
        'approval_notes': 'Approved 80m from main store',
        'requested_by_team': {'id': 'team_uuid', 'name': 'Survey Team'},
        'items': [
          {
            'item_id': 'item_uuid',
            'item_name': 'Fiber Cable',
            'unit': 'meter',
            'quantity_requested': 80,
            'quantity_approved': 80,
          },
        ],
      },
    ],
    'stage_data': {
      'survey_notes': 'Need additional cable before installation',
      'survey_feasibility_status': 'feasible',
    },
  },
  'allowed_action': 'review_survey',
};

Map<String, Object?> normalDetailJson() => {
  'data': {
    'id': 'req-1',
    'request_number': 'CRQ-20261001-ABCD',
    'status': 'survey_assigned',
    'customer_name': 'Test Customer',
    'current_team': {
      'id': 'team_uuid',
      'name': 'Survey Team',
      'functional_team_type': 'survey',
    },
  },
  'allowed_action': 'complete_survey',
};

Future<void> pumpDetail(
  WidgetTester tester,
  ConnectionRequestDetail detail,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        connectionRequestDetailProvider('req-1').overrideWith(
          (ref) async => detail,
        ),
      ],
      child: const MaterialApp(
        home: SurveyRequestDetailScreen(requestId: 'req-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('review case: Review button shown, Complete Survey hidden',
      (tester) async {
    await pumpDetail(
      tester,
      ConnectionRequestDetail.fromJson(reviewDetailJson()),
    );

    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Complete Survey'), findsNothing);
  });

  testWidgets('review case: Inventory Approval card shows what was approved',
      (tester) async {
    await pumpDetail(
      tester,
      ConnectionRequestDetail.fromJson(reviewDetailJson()),
    );

    // D21: the approval card is collapsed behind the "Inventory approval"
    // chip, and that chip row is itself a horizontal Scrollable — so the
    // vertical detail list must be named explicitly for scrollUntilVisible.
    final detailList = find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    );
    await tester.scrollUntilVisible(
      find.text('Inventory approval'),
      300,
      scrollable: detailList,
    );
    await tester.tap(find.text('Inventory approval'));
    await tester.pumpAndSettle();

    // The detail body is a lazy ListView: the approval card sits below the
    // fold, so scroll it into view before asserting on its rows.
    await tester.scrollUntilVisible(
      find.text('Inventory Approval'),
      300,
      scrollable: detailList,
    );
    await tester.pumpAndSettle();

    expect(find.text('Inventory Approval'), findsOneWidget);
    expect(find.text('approved'), findsOneWidget);
    expect(find.text('Approved 80m from main store'), findsOneWidget);
    expect(find.text('Fiber Cable'), findsOneWidget);
    expect(
      find.textContaining('Requested 80 meter'),
      findsOneWidget,
    );
    expect(find.textContaining('Approved 80 meter'), findsOneWidget);
  });

  testWidgets('normal survey: Complete Survey shown, no Review, no approval card',
      (tester) async {
    await pumpDetail(
      tester,
      ConnectionRequestDetail.fromJson(normalDetailJson()),
    );

    expect(find.text('Complete Survey'), findsOneWidget);
    expect(find.text('Review'), findsNothing);
    expect(find.text('Inventory Approval'), findsNothing);
  });
}
