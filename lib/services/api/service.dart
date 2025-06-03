import 'apis/auth.dart';
import 'apis/category.dart';
import 'apis/chat.dart';
import 'apis/job.dart';
import 'apis/location.dart';
import 'apis/purchased.dart';
import 'apis/service.dart';
import 'apis/subcategory.dart';
import 'apis/user.dart';
import 'apis/wallet.dart';
import 'apis/favorites.dart';
import 'apis/reviews.dart';

class ApiService {
  static final auth = AuthApi();
  static final user = UserApi();
  static final service = ServiceApi();
  static final job = JobApi();
  static final purchased = PurchasedApi();
  static final wallet = WalletApi();
  static final chat = ChatApi();
  static final category = CategoryApi();
  static final subcategory = SubcategoryApi();
  static final location = LocationApi();
  static final favorites = FavoritesApi();
  static final reviews = ReviewsApi();
}
