import 'package:flutter/material.dart';

/// 무한 스크롤 리스트 위젯
///
/// 페이지네이션을 지원하는 리스트를 쉽게 구현할 수 있습니다.
///
/// 사용 예시:
/// ```dart
/// InfiniteScrollList<Order>(
///   items: orders,
///   isLoading: isLoading,
///   hasMore: hasMore,
///   onLoadMore: () => loadMoreOrders(),
///   onRefresh: () => refreshOrders(),
///   itemBuilder: (context, order) => OrderCard(order: order),
///   emptyWidget: EmptyOrdersWidget(),
/// )
/// ```
class InfiniteScrollList<T> extends StatefulWidget {
  /// 표시할 아이템 목록
  final List<T> items;

  /// 현재 로딩 중인지 여부
  final bool isLoading;

  /// 더 불러올 아이템이 있는지 여부
  final bool hasMore;

  /// 추가 아이템을 로드하는 콜백
  final Future<void> Function() onLoadMore;

  /// 새로고침 콜백 (optional)
  final Future<void> Function()? onRefresh;

  /// 각 아이템을 빌드하는 함수
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// 아이템이 없을 때 표시할 위젯 (optional)
  final Widget? emptyWidget;

  /// 로딩 인디케이터 위젯 (optional)
  final Widget? loadingWidget;

  /// 스크롤 임계값 (0.0 ~ 1.0, 기본값 0.9)
  /// 스크롤 위치가 전체의 90%에 도달하면 다음 페이지를 로드합니다.
  final double loadMoreThreshold;

  /// 리스트 패딩
  final EdgeInsetsGeometry? padding;

  /// 아이템 구분선 (optional)
  final Widget? separator;

  const InfiniteScrollList({
    super.key,
    required this.items,
    required this.isLoading,
    required this.hasMore,
    required this.onLoadMore,
    required this.itemBuilder,
    this.onRefresh,
    this.emptyWidget,
    this.loadingWidget,
    this.loadMoreThreshold = 0.9,
    this.padding,
    this.separator,
  });

  @override
  State<InfiniteScrollList<T>> createState() => _InfiniteScrollListState<T>();
}

class _InfiniteScrollListState<T> extends State<InfiniteScrollList<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * widget.loadMoreThreshold) {
      if (!widget.isLoading && widget.hasMore) {
        widget.onLoadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 초기 로딩 중
    if (widget.isLoading && widget.items.isEmpty) {
      return Center(
        child: widget.loadingWidget ?? const CircularProgressIndicator(),
      );
    }

    // 아이템이 없을 때
    if (widget.items.isEmpty) {
      if (widget.onRefresh != null) {
        return RefreshIndicator(
          onRefresh: widget.onRefresh!,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: widget.emptyWidget ?? _buildDefaultEmptyWidget(),
            ),
          ),
        );
      }
      return widget.emptyWidget ?? _buildDefaultEmptyWidget();
    }

    // 아이템이 있을 때
    final listView = ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // 로딩 인디케이터 표시
        if (index == widget.items.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: widget.loadingWidget ?? const CircularProgressIndicator(),
            ),
          );
        }

        // 아이템 표시
        final item = widget.items[index];
        final itemWidget = widget.itemBuilder(context, item);

        // 구분선이 있으면 추가
        if (widget.separator != null && index < widget.items.length - 1) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              itemWidget,
              widget.separator!,
            ],
          );
        }

        return itemWidget;
      },
    );

    // Pull-to-refresh 지원
    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: listView,
      );
    }

    return listView;
  }

  Widget _buildDefaultEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '항목이 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// 그리드 형태의 무한 스크롤 위젯
class InfiniteScrollGrid<T> extends StatefulWidget {
  /// 표시할 아이템 목록
  final List<T> items;

  /// 현재 로딩 중인지 여부
  final bool isLoading;

  /// 더 불러올 아이템이 있는지 여부
  final bool hasMore;

  /// 추가 아이템을 로드하는 콜백
  final Future<void> Function() onLoadMore;

  /// 새로고침 콜백 (optional)
  final Future<void> Function()? onRefresh;

  /// 각 아이템을 빌드하는 함수
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// 아이템이 없을 때 표시할 위젯 (optional)
  final Widget? emptyWidget;

  /// 로딩 인디케이터 위젯 (optional)
  final Widget? loadingWidget;

  /// 스크롤 임계값 (0.0 ~ 1.0, 기본값 0.9)
  final double loadMoreThreshold;

  /// 그리드 패딩
  final EdgeInsetsGeometry? padding;

  /// 가로 축 개수
  final int crossAxisCount;

  /// 가로 축 간격
  final double crossAxisSpacing;

  /// 세로 축 간격
  final double mainAxisSpacing;

  /// 아이템 가로세로 비율
  final double childAspectRatio;

  const InfiniteScrollGrid({
    super.key,
    required this.items,
    required this.isLoading,
    required this.hasMore,
    required this.onLoadMore,
    required this.itemBuilder,
    this.onRefresh,
    this.emptyWidget,
    this.loadingWidget,
    this.loadMoreThreshold = 0.9,
    this.padding,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
    this.childAspectRatio = 1.0,
  });

  @override
  State<InfiniteScrollGrid<T>> createState() => _InfiniteScrollGridState<T>();
}

class _InfiniteScrollGridState<T> extends State<InfiniteScrollGrid<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * widget.loadMoreThreshold) {
      if (!widget.isLoading && widget.hasMore) {
        widget.onLoadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 초기 로딩 중
    if (widget.isLoading && widget.items.isEmpty) {
      return Center(
        child: widget.loadingWidget ?? const CircularProgressIndicator(),
      );
    }

    // 아이템이 없을 때
    if (widget.items.isEmpty) {
      if (widget.onRefresh != null) {
        return RefreshIndicator(
          onRefresh: widget.onRefresh!,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: widget.emptyWidget ?? _buildDefaultEmptyWidget(),
            ),
          ),
        );
      }
      return widget.emptyWidget ?? _buildDefaultEmptyWidget();
    }

    // 아이템이 있을 때
    final gridView = GridView.builder(
      controller: _scrollController,
      padding: widget.padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: widget.crossAxisSpacing,
        mainAxisSpacing: widget.mainAxisSpacing,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // 로딩 인디케이터 표시
        if (index == widget.items.length) {
          return Center(
            child: widget.loadingWidget ?? const CircularProgressIndicator(),
          );
        }

        // 아이템 표시
        final item = widget.items[index];
        return widget.itemBuilder(context, item);
      },
    );

    // Pull-to-refresh 지원
    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: gridView,
      );
    }

    return gridView;
  }

  Widget _buildDefaultEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '항목이 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
