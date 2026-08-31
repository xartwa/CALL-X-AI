import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/entities/customer.dart';
import '../domain/repositories/customer_repository.dart';

export '../models/customer_model.dart';

class CustomersState {
  const CustomersState(
      {this.users = const [],
      this.kpi,
      this.options,
      this.filters = const CustomerFilters(),
      this.pagination = const PaginationMeta(),
      this.isInitialLoading = false,
      this.isRefreshing = false,
      this.isSubmitting = false,
      this.isImporting = false,
      this.isExporting = false,
      this.listError,
      this.actionError});
  final List<Customer> users;
  final CustomerKpi? kpi;
  final CustomerFilterOptions? options;
  final CustomerFilters filters;
  final PaginationMeta pagination;
  final bool isInitialLoading;
  final bool isRefreshing;
  final bool isSubmitting;
  final bool isImporting;
  final bool isExporting;
  final String? listError;
  final String? actionError;
  CustomersState copyWith(
          {List<Customer>? users,
          CustomerKpi? kpi,
          CustomerFilterOptions? options,
          CustomerFilters? filters,
          PaginationMeta? pagination,
          bool? isInitialLoading,
          bool? isRefreshing,
          bool? isSubmitting,
          bool? isImporting,
          bool? isExporting,
          String? listError,
          String? actionError,
          bool clearListError = false,
          bool clearActionError = false}) =>
      CustomersState(
          users: users ?? this.users,
          kpi: kpi ?? this.kpi,
          options: options ?? this.options,
          filters: filters ?? this.filters,
          pagination: pagination ?? this.pagination,
          isInitialLoading: isInitialLoading ?? this.isInitialLoading,
          isRefreshing: isRefreshing ?? this.isRefreshing,
          isSubmitting: isSubmitting ?? this.isSubmitting,
          isImporting: isImporting ?? this.isImporting,
          isExporting: isExporting ?? this.isExporting,
          listError: clearListError ? null : listError ?? this.listError,
          actionError:
              clearActionError ? null : actionError ?? this.actionError);
}

class CustomersCubit extends Cubit<CustomersState> {
  CustomersCubit(this.repository) : super(const CustomersState());
  final CustomerRepository repository;
  Timer? _debounce;
  CancelToken? _cancelToken;
  int _listRequestId = 0;

  Future<void> loadInitial({bool resetFilters = false}) async {
    _debounce?.cancel();
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    final nextFilters = resetFilters ? const CustomerFilters() : state.filters;
    emit(state.copyWith(
      filters: nextFilters,
      isInitialLoading: true,
      clearListError: true,
    ));

    await Future.wait([
      _requestPage(page: 1),
      loadKpi(),
      loadOptions(),
    ]);

    if (!isClosed) {
      emit(state.copyWith(isInitialLoading: false, isRefreshing: false));
    }
  }

  Future<void> refresh() async {
    if (state.isRefreshing) return;
    _debounce?.cancel();
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    emit(state.copyWith(isRefreshing: true, clearListError: true));
    await Future.wait([
      _requestPage(page: state.pagination.currentPage),
      loadKpi(),
      loadOptions(),
    ]);
    if (!isClosed) {
      emit(state.copyWith(isRefreshing: false));
    }
  }

  Future<void> loadPage({int page = 1}) async {
    if (!isClosed) {
      emit(state.copyWith(isRefreshing: true, clearListError: true));
    }
    final applied = await _requestPage(page: page);
    if (applied && !isClosed) {
      emit(state.copyWith(isRefreshing: false));
    }
  }

  Future<bool> _requestPage({required int page}) async {
    final requestId = ++_listRequestId;
    final filters = state.filters;
    final pageSize = state.pagination.pageSize;

    try {
      final result = await repository.getCustomers(filters,
          page: page, pageSize: pageSize, cancelToken: _cancelToken);

      if (isClosed || requestId != _listRequestId) return false;

      final users = result.items.map(_preserveLoadedDetails).toList();
      emit(state.copyWith(
          users: users, pagination: result.pagination, clearListError: true));
      return true;
    } catch (e) {
      if (isClosed || requestId != _listRequestId) return false;

      if (e is! AppException || e.type != AppErrorType.cancelled) {
        emit(state.copyWith(listError: 'Unable to load customers.'));
      }
      return true;
    }
  }

  Future<void> loadKpi() async {
    try {
      final kpi = await repository.getKpi();
      if (!isClosed) {
        emit(state.copyWith(kpi: kpi));
      }
    } catch (_) {}
  }

  Future<void> loadOptions({String? country, String? stateValue}) async {
    try {
      final options =
          await repository.getOptions(country: country, state: stateValue);
      if (!isClosed) {
        emit(state.copyWith(options: options));
      }
    } catch (_) {}
  }

  void search(String value) {
    _debounce?.cancel();
    _cancelToken?.cancel();
    _cancelToken = CancelToken();
    _debounce = Timer(
        const Duration(milliseconds: 400),
        () => _applyFilters(CustomerFilters(
            search: value,
            country: state.filters.country,
            state: state.filters.state,
            city: state.filters.city,
            status: state.filters.status,
            leadStatus: state.filters.leadStatus,
            leadPriority: state.filters.leadPriority,
            leadQuality: state.filters.leadQuality,
            sort: state.filters.sort)));
  }

  Future<void> setFilters(CustomerFilters filters) => _applyFilters(filters);
  Future<void> _applyFilters(CustomerFilters filters) async {
    emit(state.copyWith(filters: filters));
    await loadPage();
  }

  Future<void> setSort(String sort) => _applyFilters(CustomerFilters(
      search: state.filters.search,
      country: state.filters.country,
      state: state.filters.state,
      city: state.filters.city,
      status: state.filters.status,
      leadStatus: state.filters.leadStatus,
      leadPriority: state.filters.leadPriority,
      leadQuality: state.filters.leadQuality,
      sort: sort));
  Future<void> addCustomer(Customer customer) async {
    await _action(() async {
      await repository.createCustomer(customer);
      await Future.wait([loadPage(), loadKpi()]);
    });
  }

  Future<void> updateCustomer(Customer customer) async {
    await _action(() async {
      await repository.updateCustomer(customer);
      await loadPage(page: state.pagination.currentPage);
    });
  }

  Future<void> deleteCustomer(Object id) async {
    await _action(() async {
      await repository.deleteCustomer('$id');
      await Future.wait(
          [loadPage(page: state.pagination.currentPage), loadKpi()]);
    });
  }

  Future<void> addNote(Object id, String text,
          {String author = 'Admin'}) async =>
      _action(() async {
        await repository.addNote('$id', text, author: author);
        await loadCustomerDetail('$id');
      });
  Future<void> updateNote(Object id, String noteId, String text) async =>
      _action(() async {
        await repository.updateNote('$id', noteId, text);
        await loadCustomerDetail('$id');
      });
  Future<void> deleteNote(Object id, String noteId) async => _action(() async {
        await repository.deleteNote('$id', noteId);
        await loadCustomerDetail('$id');
      });
  Future<void> addTag(Object id,
          {String? label, int? tagId, String color = '#6366F1'}) async =>
      _action(() async {
        await repository.addTag('$id',
            label: label, tagId: tagId, color: color);
        await loadCustomerDetail('$id');
      });
  Future<void> removeTag(Object id, {String? label, int? tagId}) async =>
      _action(() async {
        await repository.removeTag('$id', label: label, tagId: tagId);
        await loadCustomerDetail('$id');
      });
  Future<Customer> fetchCustomer(String id) => repository.getCustomer(id);
  Future<Customer?> loadCustomerDetail(String id) async {
    try {
      final customer = await repository.getCustomer(id);
      final users = [...state.users];
      final index = users.indexWhere((item) => item.id == id);
      if (index == -1) {
        users.add(customer);
      } else {
        users[index] = customer;
      }
      emit(state.copyWith(users: users, clearActionError: true));
      return customer;
    } catch (_) {
      emit(
          state.copyWith(actionError: 'Customer details could not be loaded.'));
      return null;
    }
  }

  Future<CustomerImportResult?> importCustomers({
    required List<int> bytes,
    required String fileName,
  }) async {
    emit(state.copyWith(isImporting: true, clearActionError: true));
    try {
      final result = await repository.importCustomers(
        bytes: bytes,
        fileName: fileName,
      );
      await Future.wait([loadPage(), loadKpi(), loadOptions()]);
      return result;
    } catch (_) {
      emit(
          state.copyWith(actionError: 'The Excel file could not be imported.'));
      return null;
    } finally {
      emit(state.copyWith(isImporting: false));
    }
  }

  Future<List<int>?> exportCustomers() async {
    emit(state.copyWith(isExporting: true, clearActionError: true));
    try {
      return await repository.exportCustomers(state.filters);
    } catch (_) {
      emit(state.copyWith(
          actionError: 'The customer export could not be created.'));
      return null;
    } finally {
      emit(state.copyWith(isExporting: false));
    }
  }

  Future<bool> dispatchCall({
    String? customerId,
    String? scenarioId,
    String? phone,
    String? fullName,
    DateTime? scheduledFor,
  }) async {
    try {
      await repository.dispatchCall(
        customerId: customerId,
        scenarioId: scenarioId,
        phone: phone,
        fullName: fullName,
        scheduledFor: scheduledFor,
      );
      return true;
    } on AppException catch (e) {
      emit(state.copyWith(actionError: e.details ?? 'The call could not be dispatched.'));
      return false;
    } catch (_) {

      emit(state.copyWith(actionError: 'The call could not be dispatched.'));
      return false;
    }
  }


  Future<List<Map<String, dynamic>>> getScenarios() =>
      repository.getScenarios();

  Future<void> _action(Future<void> Function() action) async {
    emit(state.copyWith(isSubmitting: true, clearActionError: true));
    try {
      await action();
    } catch (e) {
      String errorMessage = 'Action could not be completed.';
      if (e is AppException) {
        if (e.fieldErrors.isNotEmpty) {
          final buffer = StringBuffer();
          e.fieldErrors.forEach((field, errors) {
            buffer.writeln('$field: ${errors.join(', ')}');
          });
          errorMessage = buffer.toString().trim();
        } else if (e.details != null && e.details!.isNotEmpty) {
          errorMessage = e.details!;
        } else if (e.type == AppErrorType.network) {
          errorMessage = 'Network error. Please check your connection.';
        } else if (e.type == AppErrorType.timeout) {
          errorMessage = 'Request timed out. Please try again.';
        } else if (e.type == AppErrorType.unauthorized) {
          errorMessage = 'Session expired. Please log in again.';
        }
      }
      emit(state.copyWith(actionError: errorMessage));
    } finally {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  Customer _preserveLoadedDetails(Customer summary) {
    final existingIndex =
        state.users.indexWhere((item) => item.id == summary.id);
    if (existingIndex == -1) return summary;

    final existing = state.users[existingIndex];
    return summary.copyWith(
      notesList:
          summary.notesList.isEmpty ? existing.notesList : summary.notesList,
      notesCount: summary.notesCount == 0 && existing.notesList.isNotEmpty
          ? existing.notesCount
          : summary.notesCount,
      documents:
          summary.documents.isEmpty ? existing.documents : summary.documents,
      documentsCount:
          summary.documentsCount == 0 && existing.documents.isNotEmpty
              ? existing.documentsCount
              : summary.documentsCount,
      callLogs: summary.callLogs.isEmpty ? existing.callLogs : summary.callLogs,
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _cancelToken?.cancel();
    return super.close();
  }
}
