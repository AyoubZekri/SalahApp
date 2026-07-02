import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../controller/StatisticsController.dart';
import '../../../core/functions/format_number.dart';
import '../../controller/FinancialOverviewController.dart';
import '../../core/constant/Colorapp.dart';
import 'FinancialOverviewScreen.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../widget/statistics/StatisticsSummaryCard.dart';
import '../widget/statistics/GeneralOverviewButton.dart';
import '../widget/statistics/DateRangeDialogHelper.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.put(StatisticsController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColor.bgDark : AppColor.bgLight,
        appBar: AppBar(
          title: Text(
            "الإحصائيات",
            style: TextStyle(
              color: theme.primaryColor,
              fontFamily: "Cairo",
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          backgroundColor: isDark ? AppColor.cardDark : AppColor.cardLight,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        body: GetBuilder<StatisticsController>(
          builder: (ctrl) {
            if (ctrl.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: ctrl.fetchData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(
                            Icons.bar_chart_rounded,
                            color: AppColor.primaryApp,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "مقاييس الأداء",
                            style: TextStyle(
                              fontFamily: "Cairo",
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      // Tabs (Filters) Segmented Control Style
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColor.cardDark
                              : AppColor.borderLight.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildTab(
                                "سنة",
                                ctrl.currentFilter == FilterType.year,
                                () => ctrl.changeFilter(FilterType.year),
                                isDark),
                            _buildTab(
                                "شهر",
                                ctrl.currentFilter == FilterType.month,
                                () => ctrl.changeFilter(FilterType.month),
                                isDark),
                            _buildTab(
                                "أسبوع",
                                ctrl.currentFilter == FilterType.week,
                                () => ctrl.changeFilter(FilterType.week),
                                isDark),
                            _buildTab(
                                "يوم",
                                ctrl.currentFilter == FilterType.day,
                                () => ctrl.changeFilter(FilterType.day),
                                isDark),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Chart Card
                      Container(
                        padding: const EdgeInsets.only(
                            top: 24, bottom: 16, right: 16, left: 16),
                        decoration: BoxDecoration(
                          color:
                              isDark ? AppColor.cardDark : AppColor.cardLight,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: _buildLineChart(ctrl, theme, isDark),
                      ),
                      const SizedBox(height: 24),

                      // 2-Column Summary Cards
                      _buildSummaryColumns(ctrl, isDark),
                      const SizedBox(height: 32),

                      // General Overview
                      Text(
                        "نظرة مالية عامة",
                        style: TextStyle(
                          fontFamily: "Cairo",
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GeneralOverviewButton(
                        theme: theme,
                        isDark: isDark,
                        onTap: () => DateRangeDialogHelper.showDateRangeDialog(context, isDark),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTab(
      String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? AppColor.primaryApp.withOpacity(0.2)
                    : AppColor.cardLight)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected && !isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Cairo",
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
                color: isSelected
                    ? (isDark ? AppColor.primaryApp : AppColor.primaryApp)
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(
      StatisticsController ctrl, ThemeData theme, bool isDark) {
    if (ctrl.breakdownList.isEmpty) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: const Text("لا توجد بيانات لهذه الفترة",
            style: TextStyle(fontFamily: "Cairo")),
      );
    }

    return SizedBox(
      height: 300,
      width: double.infinity,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: ctrl.maxAmount,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${formatAmount(spot.y)} دج',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                  color: isDark ? Colors.white24 : Colors.black12, width: 1),
              left: BorderSide(
                  color: isDark ? Colors.white24 : Colors.black12, width: 1),
              right: BorderSide.none,
              top: BorderSide.none,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: ctrl.breakdownList.length > 8
                    ? (ctrl.breakdownList.length / 8).ceilToDouble()
                    : 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  int idx = value.toInt();
                  if (idx < 0 || idx >= ctrl.breakdownList.length)
                    return const SizedBox.shrink();

                  String period = ctrl.breakdownList[idx]["period"];

                  if (ctrl.currentFilter == FilterType.day) {
                    period = period.split(":")[0];
                  } else if (ctrl.currentFilter == FilterType.week) {
                    if (period.length > 2) {
                      if (period == "الأحد")
                        period = "أحد";
                      else if (period == "الإثنين")
                        period = "إثن";
                      else if (period == "الثلاثاء")
                        period = "ثلا";
                      else if (period == "الأربعاء")
                        period = "أرب";
                      else if (period == "الخميس")
                        period = "خمي";
                      else if (period == "الجمعة")
                        period = "جمع";
                      else if (period == "السبت")
                        period = "سبت";
                      else
                        period = period.substring(2, 3);
                    }
                  } else if (ctrl.currentFilter == FilterType.month) {
                    period = period.replaceAll("الأسبوع ", "");
                  } else {
                    if (period.length > 3) period = period.substring(0, 3);
                    if (period == "جان")
                      period = "Jan";
                    else if (period == "فيف")
                      period = "Feb";
                    else if (period == "مار")
                      period = "Mar";
                    else if (period == "أفر")
                      period = "Apr";
                    else if (period == "ماي")
                      period = "May";
                    else if (period == "جوا")
                      period = "Jun";
                    else if (period == "جوي")
                      period = "Jul";
                    else if (period == "أوت")
                      period = "Aug";
                    else if (period == "سبت")
                      period = "Sep";
                    else if (period == "أكت")
                      period = "Oct";
                    else if (period == "نوف")
                      period = "Nov";
                    else if (period == "ديس") period = "Dec";
                  }

                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8,
                    child: Text(
                      period,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value == 0) return const SizedBox.shrink();
                  String text = formatAmount(value);
                  if (value >= 1000) {
                    text = "${(value / 1000).toStringAsFixed(1)}k";
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      text,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(ctrl.breakdownList.length, (index) {
                final item = ctrl.breakdownList[index];
                final double sales = (item["sales"] as num?)?.toDouble() ?? 0.0;
                return FlSpot(index.toDouble(), sales);
              }),
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Color(0xFF00B09B), Color(0xFF96C93D)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: const Color(0xFF00B09B),
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00B09B).withOpacity(0.3),
                    const Color(0xFF96C93D).withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryColumns(StatisticsController ctrl, bool isDark) {
    double totalSales = ctrl.totalSales;
    double totalExpenses = ctrl.totalPurchases;

    return Row(
      children: [
        Expanded(
          child: StatisticsSummaryCard(
            title: "المصروفات",
            amount: formatAmount(totalExpenses),
            icon: Icons.trending_down_rounded,
            color: Colors.red,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatisticsSummaryCard(
            title: "إجمالي المبيعات",
            amount: formatAmount(totalSales),
            icon: Icons.trending_up_rounded,
            color: const Color(0xFF00B09B),
            isDark: isDark,
          ),
        ),
      ],
    );
  }



}
