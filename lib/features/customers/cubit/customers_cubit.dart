import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/preferences_service.dart';
import '../models/customer_model.dart';

export '../models/customer_model.dart';

class CustomersState {
  final List<User> users;

  CustomersState({required this.users});
}

class CustomersCubit extends Cubit<CustomersState> {
  final PreferencesService _preferencesService;

  CustomersCubit(this._preferencesService) : super(CustomersState(users: [])) {
    _init();
  }

  void _init() {
    final loaded = _preferencesService.loadCustomers();
    if (loaded.isEmpty) {
      final defaultUsers = [
        User(
          id: 0,
          fullName: "John Smith",
          companyName: "ABC Construction",
          jobTitle: "Estimator & Partner",
          email: "john.smith@abcconstruction.ca",
          phone: "0912 345 6789",
          website: "https://abcconstruction.ca",
          address: "1050 W Pender St, Suite 1200",
          city: "Vancouver",
          state: "BC",
          country: "Canada",
          companyType: "GC",
          leadStatus: "Contacted",
          leadPriority: "Hot",
          leadQuality: "Excellent",
          lastContactResult: "Interested",
          nextFollowUpDate: "2026/08/20",
          createdAt: "2026/06/15",
          lastContact: "2026/08/10",
          status: "Active",
          reasonForContact:
              "Request for tender estimation and commercial quote",
          tags: ["GC", "Hot Lead", "Vancouver", "Commercial"],
          notesList: [
            CustomerNote(
              id: 'n1',
              content:
                  'حتما تماس مشتری پیگیری شود و جهت ارسال پیش‌فاکتور پکیج اختصاصی تماس گرفته شود.',
              date: '2026/08/10 14:30',
              author: 'آرتا رجبان',
            ),
            CustomerNote(
              id: 'n2',
              content:
                  'مشتری تمایل زیادی به عقد قرارداد سالانه دارد. درخواست تخفیف ۵ درصدی داشت.',
              date: '2026/08/08 11:15',
              author: 'Admin',
            ),
          ],
          documents: [
            CustomerDocument(
              id: 'd1',
              name: 'Commercial_Quote_v2.pdf',
              size: '2.4 MB',
              type: 'Quote',
              uploadDate: '2026/08/09',
            ),
            CustomerDocument(
              id: 'd2',
              name: 'Architectural_Drawings.dwg',
              size: '14.8 MB',
              type: 'Drawings',
              uploadDate: '2026/08/05',
            ),
          ],
        ),
        User(
          id: 1,
          fullName: "Sarah Connor",
          companyName: "Apex Real Estate Development",
          jobTitle: "Project Director",
          email: "sconnor@apexdevelopments.com",
          phone: "0935 111 2233",
          website: "https://apexdevelopments.com",
          address: "450 8th Ave SW",
          city: "Calgary",
          state: "AB",
          country: "Canada",
          companyType: "Developer",
          leadStatus: "Qualified",
          leadPriority: "Warm",
          leadQuality: "Good",
          lastContactResult: "Meeting booked",
          nextFollowUpDate: "2026/08/22",
          createdAt: "2026/07/01",
          lastContact: "2026/08/12",
          status: "Active",
          reasonForContact: "New multi-family residential towers project",
          tags: ["Developer", "Branding", "Calgary"],
          notesList: [
            CustomerNote(
              id: 'n3',
              content:
                  'جلسه آنلاین برای روز دوشنبه تنظیم شد. پروپوزال فنی ارسال شد.',
              date: '2026/08/12 16:45',
              author: 'آرتا رجبان',
            ),
          ],
          documents: [
            CustomerDocument(
              id: 'd3',
              name: 'Project_Brief_Towers.pdf',
              size: '5.1 MB',
              type: 'Brief',
              uploadDate: '2026/08/11',
            ),
          ],
        ),
        User(
          id: 2,
          fullName: "Michael Chang",
          companyName: "Nexus Digital Agency",
          jobTitle: "Founder & CEO",
          email: "michael@nexusagency.io",
          phone: "0930 777 8899",
          website: "https://nexusagency.io",
          address: "200 Bay St, Suite 3000",
          city: "Toronto",
          state: "ON",
          country: "Canada",
          companyType: "Agency",
          leadStatus: "New",
          leadPriority: "Hot",
          leadQuality: "Excellent",
          lastContactResult: "Call back",
          nextFollowUpDate: "2026/08/18",
          createdAt: "2026/08/01",
          lastContact: "2026/08/13",
          status: "Active",
          reasonForContact: "Agency white-label partnership inquiry",
          tags: ["Agency", "Startup", "Hot Lead", "Toronto"],
          notesList: [
            CustomerNote(
              id: 'n4',
              content:
                  'علاقه‌مند به یکپارچه‌سازی هوش مصنوعی صوتی برای بیش از ۵۰ اکانت مشتریان خود.',
              date: '2026/08/13 10:20',
              author: 'Admin',
            ),
          ],
          documents: [
            CustomerDocument(
              id: 'd4',
              name: 'Agency_Partnership_Proposal.pdf',
              size: '3.2 MB',
              type: 'Proposal',
              uploadDate: '2026/08/13',
            ),
          ],
        ),
      ];
      _saveToPrefs(defaultUsers);
      emit(CustomersState(users: defaultUsers));
    } else {
      final users = loaded.map((json) => User.fromJson(json)).toList();
      emit(CustomersState(users: users));
    }
  }

  void _saveToPrefs(List<User> users) {
    final list = users.map((u) => u.toJson()).toList();
    _preferencesService.saveCustomers(list);
  }

  void addCustomer(User user) {
    final nextId = state.users.isEmpty
        ? 0
        : state.users.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1;
    final userWithId = user.copyWith(id: nextId);

    final updated = List<User>.from(state.users)..add(userWithId);
    _saveToPrefs(updated);
    emit(CustomersState(users: updated));
  }

  void updateCustomer(User updatedUser) {
    final updatedList = state.users.map((user) {
      return user.id == updatedUser.id ? updatedUser : user;
    }).toList();
    _saveToPrefs(updatedList);
    emit(CustomersState(users: updatedList));
  }

  void deleteCustomer(int id) {
    final updatedList = state.users.where((user) => user.id != id).toList();
    _saveToPrefs(updatedList);
    emit(CustomersState(users: updatedList));
  }

  void addNote(int customerId, String noteText, {String author = 'Admin'}) {
    if (noteText.trim().isEmpty) return;

    final now = DateTime.now();
    final formattedDate =
        "${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final note = CustomerNote(
      id: 'note_${DateTime.now().millisecondsSinceEpoch}',
      content: noteText.trim(),
      date: formattedDate,
      author: author,
    );

    final updatedList = state.users.map((user) {
      if (user.id == customerId) {
        final updatedNotes = List<CustomerNote>.from(user.notesList)
          ..insert(0, note);
        return user.copyWith(
          notesList: updatedNotes,
          notes: noteText.trim(),
          lastContact:
              "${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}",
        );
      }
      return user;
    }).toList();

    _saveToPrefs(updatedList);
    emit(CustomersState(users: updatedList));
  }

  void deleteNote(int customerId, String noteId) {
    final updatedList = state.users.map((user) {
      if (user.id == customerId) {
        final updatedNotes =
            user.notesList.where((n) => n.id != noteId).toList();
        return user.copyWith(notesList: updatedNotes);
      }
      return user;
    }).toList();

    _saveToPrefs(updatedList);
    emit(CustomersState(users: updatedList));
  }

  void updateNote(int customerId, String noteId, String newText) {
    final updatedList = state.users.map((user) {
      if (user.id == customerId) {
        final updatedNotes = user.notesList.map((n) {
          if (n.id == noteId) {
            return n.copyWith(content: newText.trim());
          }
          return n;
        }).toList();
        return user.copyWith(notesList: updatedNotes);
      }
      return user;
    }).toList();

    _saveToPrefs(updatedList);
    emit(CustomersState(users: updatedList));
  }

  void addTag(int customerId, String tag) {
    final cleanTag = tag.trim();
    if (cleanTag.isEmpty) return;

    final updatedList = state.users.map((user) {
      if (user.id == customerId) {
        if (!user.tags.contains(cleanTag)) {
          final updatedTags = List<String>.from(user.tags)..add(cleanTag);
          return user.copyWith(tags: updatedTags);
        }
      }
      return user;
    }).toList();

    _saveToPrefs(updatedList);
    emit(CustomersState(users: updatedList));
  }

  void removeTag(int customerId, String tag) {
    final updatedList = state.users.map((user) {
      if (user.id == customerId) {
        final updatedTags = user.tags.where((t) => t != tag).toList();
        return user.copyWith(tags: updatedTags);
      }
      return user;
    }).toList();

    _saveToPrefs(updatedList);
    emit(CustomersState(users: updatedList));
  }
}
