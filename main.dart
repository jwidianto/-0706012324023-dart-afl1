import 'dart:convert';
import 'dart:io';

// Mengambil data produk dari API
Future<List<dynamic>> fetchProducts() async {
  final url = 'https://fakestoreapi.com/products';
  final httpClient = HttpClient();

  try {
    final request = await httpClient.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode == 200) {
      final jsonString = await response.transform(utf8.decoder).join();
      return json.decode(jsonString);
    } else {
      throw Exception("Gagal mengambil data produk: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception("Terjadi kesalahan: $e");
  } finally {
    httpClient.close();
  }
}

// Menampilkan daftar produk
void displayProducts(List<dynamic> products) {
  print("\nDaftar Produk:");
  for (var product in products) {
    print("ID: ${product['id']} - ${product['title']} - \$${product['price']}");
  }
}

// Menambahkan orderan ke dalam keranjang
Map<int, int> addOrders(Map<int, int> orders, List<dynamic> products) {
  Map<int, int> cart = {};

  print("\nMemasukkan orderan ke dalam keranjang:");
  for (var entry in orders.entries) {
    var product = products.firstWhere((p) => p['id'] == entry.key, orElse: () => null);
    if (product != null) {
      print("Menambahkan: ${product['title']} - Jumlah: ${entry.value}");
      cart[entry.key] = entry.value;
    } else {
      print("Produk dengan ID ${entry.key} tidak ditemukan.");
    }
  }

  return cart;
}

// Fungsi untuk menampilkan isi keranjang dan total harga
void displayCart(Map<int, int> cart, List<dynamic> products) {
  print("\nKeranjang Belanja:");
  double total = 0.0;

  for (var entry in cart.entries) {
    var product = products.firstWhere((p) => p['id'] == entry.key, orElse: () => null);
    if (product != null) {
      double price = (product['price'] is int) ? (product['price'] as int).toDouble() : product['price'];
      double subtotal = price * entry.value;
      total += subtotal;
      print("${product['title']} x ${entry.value} = \$${subtotal.toStringAsFixed(2)}");
    }
  }

  print("\nTotal Harga: \$${total.toStringAsFixed(2)}");
}

void main() async {
  print("Mengambil daftar produk...");
  try {
    List<dynamic> products = await fetchProducts();
    if (products.isEmpty) {
      print("Tidak ada produk yang tersedia.");
      return;
    }

    displayProducts(products);

    // Mendambahkan orderan
    var orders = {
      12: 4,
      5: 23,
      11: 34,
    };

    Map<int, int> cart = addOrders(orders, products);
    displayCart(cart, products);

  } catch (e) {
    print("Error: $e");
  }
}
