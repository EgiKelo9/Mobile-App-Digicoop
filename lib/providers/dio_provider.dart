import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:digicoop/constants/constants.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioProvider {
  // user provider
  // get token user
  Future<dynamic> getTokenUser(String email, String password) async {
    try {
      var response = await Dio().post(loginUserURL, data: {
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200 && response.data != '') {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('tokenUser', response.data);
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return error;
    }
  }

  // get user
  Future<dynamic> getUser(String token) async {
    try {
      var response = await Dio().get(userDashboardURL,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }));
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Tangani berbagai jenis error
        if (e.response?.statusCode == 401) {
          // Token tidak valid
          throw Exception('Unauthorized: Token invalid or expired');
        } else if (e.response?.statusCode == 500) {
          // Error server
          throw Exception(
              'Internal Server Error: ${e.response?.data['message'] ?? 'Unknown error'}');
        }
      } else {
        // Error koneksi
        throw Exception('Connection error');
      }
    }
  }

  // get user history simpanan
  Future<dynamic> getUserHistorySimpanan(
    String token, {
    String? filterType,
    String? selectedMonth,
    String? selectedYear,
  }) async {
    try {
      // Build query parameters
      Map<String, dynamic> queryParams = {};
      if (filterType != null) {
        queryParams['filter_type'] = filterType;
        if (filterType == 'Pilih Bulan' && selectedMonth != null) {
          queryParams['selected_month'] = selectedMonth;
        }
        if (filterType == 'Pilih Tahun' && selectedYear != null) {
          queryParams['selected_year'] = selectedYear;
        }
      }

      var response = await Dio().get(
        userHistorySimpananURL,
        queryParameters: queryParams,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        }),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.statusCode == 401) {
          throw Exception('Unauthorized: Token invalid or expired');
        } else if (e.response?.statusCode == 500) {
          throw Exception(
              'Internal Server Error: ${e.response?.data['message'] ?? 'Unknown error'}');
        }
      }
      throw Exception('Connection error');
    }
  }

  // get user history pinjaman
  Future<dynamic> getUserHistoryPinjaman(
    String token, {
    String? filterType,
    String? selectedMonth,
    String? selectedYear,
  }) async {
    try {
      // Build query parameters
      Map<String, dynamic> queryParams = {};
      if (filterType != null) {
        queryParams['filter_type'] = filterType;
        if (filterType == 'Pilih Bulan' && selectedMonth != null) {
          queryParams['selected_month'] = selectedMonth;
        }
        if (filterType == 'Pilih Tahun' && selectedYear != null) {
          queryParams['selected_year'] = selectedYear;
        }
      }

      var response = await Dio().get(
        userHistoryPinjamanURL,
        queryParameters: queryParams,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        }),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.statusCode == 401) {
          throw Exception('Unauthorized: Token invalid or expired');
        } else if (e.response?.statusCode == 500) {
          throw Exception(
              'Internal Server Error: ${e.response?.data['message'] ?? 'Unknown error'}');
        }
      }
      throw Exception('Connection error');
    }
  }

  // get user history penarikan
  Future<dynamic> getUserHistoryPenarikan(
    String token, {
    String? filterType,
    String? selectedMonth,
    String? selectedYear,
  }) async {
    try {
      // Build query parameters
      Map<String, dynamic> queryParams = {};
      if (filterType != null) {
        queryParams['filter_type'] = filterType;
        if (filterType == 'Pilih Bulan' && selectedMonth != null) {
          queryParams['selected_month'] = selectedMonth;
        }
        if (filterType == 'Pilih Tahun' && selectedYear != null) {
          queryParams['selected_year'] = selectedYear;
        }
      }

      var response = await Dio().get(
        userHistoryPenarikanURL,
        queryParameters: queryParams,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        }),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.statusCode == 401) {
          throw Exception('Unauthorized: Token invalid or expired');
        } else if (e.response?.statusCode == 500) {
          throw Exception(
              'Internal Server Error: ${e.response?.data['message'] ?? 'Unknown error'}');
        }
      }
      throw Exception('Connection error');
    }
  }

  // download simpanan pdf
  Future<String> downloadSimpananPDF(
    String token, {
    String? filterType,
    String? selectedMonth,
    String? selectedYear,
  }) async {
    try {
      // Prepare query parameters based on provided filters
      Map<String, dynamic> queryParams = {};
      if (filterType != null) {
        queryParams['filter_type'] = filterType;
        if (filterType == 'Pilih Bulan' && selectedMonth != null) {
          queryParams['selected_month'] = selectedMonth;
        }
        if (filterType == 'Pilih Tahun' && selectedYear != null) {
          queryParams['selected_year'] = selectedYear;
        }
      }

      // Make the API request to download the file
      final response = await Dio().get(
        userSimpananPDFURL,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/pdf',
          },
          responseType: ResponseType.bytes,
        ),
      );

      // Get the appropriate directory for file storage
      Directory? directory;
      try {
        directory = await getExternalStorageDirectory();
      } catch (e) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Tidak dapat mengakses direktori penyimpanan');
      }

      // Create a unique filename using current timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'riwayat_transaksi_$timestamp.pdf';
      final filePath = '${directory.path}/$fileName';

      // Save the downloaded data to a file
      final file = File(filePath);
      await file.writeAsBytes(response.data);

      return filePath;
    } on DioException catch (e) {
      // Handle specific Dio-related errors
      if (e.response != null) {
        if (e.response?.statusCode == 401) {
          throw Exception('Unauthorized: Token invalid or expired');
        } else if (e.response?.statusCode == 500) {
          throw Exception(
              'Internal Server Error: ${e.response?.data['message'] ?? 'Unknown error'}');
        }
      }
      throw Exception('Connection error');
    } catch (e) {
      throw Exception('Gagal menyimpan file: $e');
    }
  }

  // download pinjaman pdf
  Future<String> downloadPinjamanPDF(
    String token, {
    String? filterType,
    String? selectedMonth,
    String? selectedYear,
  }) async {
    try {
      // Prepare query parameters based on provided filters
      Map<String, dynamic> queryParams = {};
      if (filterType != null) {
        queryParams['filter_type'] = filterType;
        if (filterType == 'Pilih Bulan' && selectedMonth != null) {
          queryParams['selected_month'] = selectedMonth;
        }
        if (filterType == 'Pilih Tahun' && selectedYear != null) {
          queryParams['selected_year'] = selectedYear;
        }
      }

      // Make the API request to download the file
      final response = await Dio().get(
        userPinjamanPDFURL,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/pdf',
          },
          responseType: ResponseType.bytes,
        ),
      );

      // Get the appropriate directory for file storage
      Directory? directory;
      try {
        directory = await getExternalStorageDirectory();
      } catch (e) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Tidak dapat mengakses direktori penyimpanan');
      }

      // Create a unique filename using current timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'riwayat_transaksi_$timestamp.pdf';
      final filePath = '${directory.path}/$fileName';

      // Save the downloaded data to a file
      final file = File(filePath);
      await file.writeAsBytes(response.data);

      return filePath;
    } on DioException catch (e) {
      // Handle specific Dio-related errors
      if (e.response != null) {
        if (e.response?.statusCode == 401) {
          throw Exception('Unauthorized: Token invalid or expired');
        } else if (e.response?.statusCode == 500) {
          throw Exception(
              'Internal Server Error: ${e.response?.data['message'] ?? 'Unknown error'}');
        }
      }
      throw Exception('Connection error');
    } catch (e) {
      throw Exception('Gagal menyimpan file: $e');
    }
  }

  // download penarikan pdf
  Future<String> downloadPenarikanPDF(
    String token, {
    String? filterType,
    String? selectedMonth,
    String? selectedYear,
  }) async {
    try {
      // Prepare query parameters based on provided filters
      Map<String, dynamic> queryParams = {};
      if (filterType != null) {
        queryParams['filter_type'] = filterType;
        if (filterType == 'Pilih Bulan' && selectedMonth != null) {
          queryParams['selected_month'] = selectedMonth;
        }
        if (filterType == 'Pilih Tahun' && selectedYear != null) {
          queryParams['selected_year'] = selectedYear;
        }
      }

      // Make the API request to download the file
      final response = await Dio().get(
        userPenarikanPDFURL,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/pdf',
          },
          responseType: ResponseType.bytes,
        ),
      );

      // Get the appropriate directory for file storage
      Directory? directory;
      try {
        directory = await getExternalStorageDirectory();
      } catch (e) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Tidak dapat mengakses direktori penyimpanan');
      }

      // Create a unique filename using current timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'riwayat_transaksi_$timestamp.pdf';
      final filePath = '${directory.path}/$fileName';

      // Save the downloaded data to a file
      final file = File(filePath);
      await file.writeAsBytes(response.data);

      return filePath;
    } on DioException catch (e) {
      // Handle specific Dio-related errors
      if (e.response != null) {
        if (e.response?.statusCode == 401) {
          throw Exception('Unauthorized: Token invalid or expired');
        } else if (e.response?.statusCode == 500) {
          throw Exception(
              'Internal Server Error: ${e.response?.data['message'] ?? 'Unknown error'}');
        }
      }
      throw Exception('Connection error');
    } catch (e) {
      throw Exception('Gagal menyimpan file: $e');
    }
  }

  // get user card
  Future<dynamic> getUserCard(String token) async {
    try {
      var response = await Dio().get(userAjukanSimpananURL,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }));
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Tangani berbagai jenis error
        if (e.response?.statusCode == 401) {
          // Token tidak valid
          throw Exception('Unauthorized: Token invalid or expired');
        } else if (e.response?.statusCode == 500) {
          // Error server
          throw Exception(
              'Internal Server Error: ${e.response?.data['message'] ?? 'Unknown error'}');
        }
      } else {
        // Error koneksi
        throw Exception('Connection error');
      }
    }
  }

  // store new tabungan
  Future<dynamic> storeUserAjukanSimpanan(String token, String type,
      double amount, int duration, String? description) async {
    int transactionTypeId = 1;
    switch (type) {
      case "Tabungan":
        transactionTypeId = 1;
        break;
      case "Deposito":
        switch (duration) {
          case 3:
            transactionTypeId = 2;
            break;
          case 6:
            transactionTypeId = 3;
            break;
          case 12:
            transactionTypeId = 4;
            break;
        }
    }
    try {
      var response = await Dio().post(userAjukanSimpananURL,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }),
          data: {
            'transaction_type_id': transactionTypeId,
            'amount': amount,
            'duration': duration,
            'description': description,
          });
      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        print('Error response: ${response.data}');
        return 'Error: ${response.statusCode}';
      }
    } on DioException catch (error) {
      print(
          'DioError: ${error.response?.data}'); // tambahkan ini untuk melihat pesan error detail
      return error;
    }
  }

  // store new pinjaman
  Future<dynamic> storeUserAjukanPinjaman(String token, String type,
      double amount, int duration, String? description) async {
    int transactionTypeId = 6;
    switch (duration) {
      case 3:
        transactionTypeId = 6;
        break;
      case 6:
        transactionTypeId = 7;
        break;
      case 12:
        transactionTypeId = 8;
        break;
    }
    try {
      var response = await Dio().post(userAjukanPinjamanURL,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }),
          data: {
            'transaction_type_id': transactionTypeId,
            'amount': amount,
            'duration': duration,
            'description': description,
          });
      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        print('Error response: ${response.data}');
        return 'Error: ${response.statusCode}';
      }
    } on DioException catch (error) {
      print(
          'DioError: ${error.response?.data}'); // tambahkan ini untuk melihat pesan error detail
      return error;
    }
  }

  // store new penarikan
  Future<dynamic> storeUserAjukanPenarikan(
      String token, String type, double amount, String? description) async {
    int transactionTypeId = 5;
    try {
      var response = await Dio().post(userAjukanPenarikanURL,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }),
          data: {
            'transaction_type_id': transactionTypeId,
            'amount': amount,
            'description': description,
          });
      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        print('Error response: ${response.data}');
        return response.data;
      }
    } on DioException catch (error) {
      print(
          'DioError: ${error.response?.data}'); // tambahkan ini untuk melihat pesan error detail
      return error;
    }
  }

  // get user profil
  Future<dynamic> getUserProfil(String token) async {
    try {
      var response = await Dio().get(userProfilURL,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }));
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Tangani berbagai jenis error
        if (e.response?.statusCode == 401) {
          // Token tidak valid
          throw Exception('Unauthorized: Token invalid or expired');
        } else if (e.response?.statusCode == 500) {
          // Error server
          throw Exception(
              'Internal Server Error: ${e.response?.data['message'] ?? 'Unknown error'}');
        }
      } else {
        // Error koneksi
        throw Exception('Connection error');
      }
    }
  }

  // update user profil
  Future<dynamic> updateUserProfil(
      String token, String? name, String? username, String? address) async {
    try {
      // Create a map that only includes the non-null field we want to update
      Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (username != null) data['username'] = username;
      if (address != null) data['address'] = address;

      var response = await Dio().put(
        editUserProfilURL,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        }),
        // Only send the field being updated
        data: data,
      );

      if (response.statusCode == 200) {
        return response.statusCode;
      } else {
        print('Error response: ${response.data}');
        return response.data['message'] ?? 'Update failed';
      }
    } on DioException catch (error) {
      print('DioError: ${error.response?.data}');
      throw Exception(
          error.response?.data?['message'] ?? 'Network error occurred');
    }
  }

  // =================================================================================================================

  // employee provider
  // get token employee
  Future<dynamic> getTokenEmployee(String email, String password) async {
    try {
      var response = await Dio().post(loginEmployeeURL, data: {
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200 && response.data != '') {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('tokenEmployee', response.data);
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return error;
    }
  }

  // get employee
  Future<dynamic> getEmployee(String token) async {
    try {
      var response = await Dio().get(employeeDashboardURL,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }));
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Tangani berbagai jenis error
        if (e.response?.statusCode == 401) {
          // Token tidak valid
          throw Exception('Unauthorized: Token invalid or expired');
        } else if (e.response?.statusCode == 500) {
          // Error server
          throw Exception(
              'Internal Server Error: ${e.response?.data['message'] ?? 'Unknown error'}');
        }
      } else {
        // Error koneksi
        throw Exception('Connection error');
      }
    }
  }

  // get transaksi diproses
  Future<dynamic> getTransaksiDiproses(String token) async {
    try {
      var response = await Dio().get(employeeTransaksiURL,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }));
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Tangani berbagai jenis error
        if (e.response?.statusCode == 401) {
          // Token tidak valid
          throw Exception('Unauthorized: Token invalid or expired');
        } else if (e.response?.statusCode == 500) {
          // Error server
          throw Exception(
              'Internal Server Error: ${e.response?.data['message'] ?? 'Unknown error'}');
        }
      } else {
        // Error koneksi
        throw Exception('Connection error');
      }
    }
  }

  // get employee
  Future<dynamic> getTransaksiTersisa(String token) async {
    try {
      var response = await Dio().get(employeeTersisaURL,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }));
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Tangani berbagai jenis error
        if (e.response?.statusCode == 401) {
          // Token tidak valid
          throw Exception('Unauthorized: Token invalid or expired');
        } else if (e.response?.statusCode == 500) {
          // Error server
          throw Exception(
              'Internal Server Error: ${e.response?.data['message'] ?? 'Unknown error'}');
        }
      } else {
        // Error koneksi
        throw Exception('Connection error');
      }
    }
  }

  // get employee
  Future<dynamic> getDaftarNasabah(String token) async {
    try {
      var response = await Dio().get(employeeGetNasabahURL,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }));
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Tangani berbagai jenis error
        if (e.response?.statusCode == 401) {
          // Token tidak valid
          throw Exception('Unauthorized: Token invalid or expired');
        } else if (e.response?.statusCode == 500) {
          // Error server
          throw Exception(
              'Internal Server Error: ${e.response?.data['message'] ?? 'Unknown error'}');
        }
      } else {
        // Error koneksi
        throw Exception('Connection error');
      }
    }
  }

  // get tabungan for employee
  Future<dynamic> getTabunganForEmployee(String token) async {
    try {
      var response = await Dio().get(employeeDaftarTabunganURL,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }));
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Tangani berbagai jenis error
        if (e.response?.statusCode == 401) {
          // Token tidak valid
          throw Exception('Unauthorized: Token invalid or expired');
        } else if (e.response?.statusCode == 500) {
          // Error server
          throw Exception(
              'Internal Server Error: ${e.response?.data['message'] ?? 'Unknown error'}');
        }
      } else {
        // Error koneksi
        throw Exception('Connection error');
      }
    }
  }

  // store new penarikan
  Future<dynamic> processTabunganForEmployee(
      String token, int trx_id, String status) async {
    try {
      var response = await Dio().put(employeeProsesTabunganURL,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }),
          data: {
            'trx_id': trx_id,
            'status': status,
          });
      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        print('Error response: ${response.data}');
        return response.data;
      }
    } on DioException catch (error) {
      print(
          'DioError: ${error.response?.data}'); // tambahkan ini untuk melihat pesan error detail
      return error;
    }
  }

  // get tabungan for employee
  Future<dynamic> getPenarikanForEmployee(String token) async {
    try {
      var response = await Dio().get(employeeDaftarPenarikanURL,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }));
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Tangani berbagai jenis error
        if (e.response?.statusCode == 401) {
          // Token tidak valid
          throw Exception('Unauthorized: Token invalid or expired');
        } else if (e.response?.statusCode == 500) {
          // Error server
          throw Exception(
              'Internal Server Error: ${e.response?.data['message'] ?? 'Unknown error'}');
        }
      } else {
        // Error koneksi
        throw Exception('Connection error');
      }
    }
  }

  // store new penarikan
  Future<dynamic> processPenarikanForEmployee(
      String token, int trx_id, String status) async {
    try {
      var response = await Dio().put(employeeProsesPenarikanURL,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }),
          data: {
            'trx_id': trx_id,
            'status': status,
          });
      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        print('Error response: ${response.data}');
        return response.data;
      }
    } on DioException catch (error) {
      print(
          'DioError: ${error.response?.data}'); // tambahkan ini untuk melihat pesan error detail
      return error;
    }
  }

  // get tabungan for employee
  Future<dynamic> getAddTabunganForEmployee(String token) async {
    try {
      var response = await Dio().get(employeeTambahTabunganURL,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }));
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Tangani berbagai jenis error
        if (e.response?.statusCode == 401) {
          // Token tidak valid
          throw Exception('Unauthorized: Token invalid or expired');
        } else if (e.response?.statusCode == 500) {
          // Error server
          throw Exception(
              'Internal Server Error: ${e.response?.data['message'] ?? 'Unknown error'}');
        }
      } else {
        // Error koneksi
        throw Exception('Connection error');
      }
    }
  }

  // store new tabungan
  Future<dynamic> storeAddTabunganForEmployee(String token, String card_number,
      double amount, DateTime created_at, String description) async {
    try {
      var response = await Dio().post(employeeTambahTabunganURL,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }),
          data: {
            'card_number': card_number,
            'amount': amount,
            'created_at': created_at.toIso8601String(),
            'description': description,
          });
      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        print('Error response: ${response.data}');
        return response.data;
      }
    } on DioException catch (error) {
      print(
          'DioError: ${error.response?.data}'); // tambahkan ini untuk melihat pesan error detail
      return error;
    }
  }

  // get Penarikan for employee
  Future<dynamic> getAddPenarikanForEmployee(String token) async {
    try {
      var response = await Dio().get(employeeTambahPenarikanURL,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }));
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Tangani berbagai jenis error
        if (e.response?.statusCode == 401) {
          // Token tidak valid
          throw Exception('Unauthorized: Token invalid or expired');
        } else if (e.response?.statusCode == 500) {
          // Error server
          throw Exception(
              'Internal Server Error: ${e.response?.data['message'] ?? 'Unknown error'}');
        }
      } else {
        // Error koneksi
        throw Exception('Connection error');
      }
    }
  }

  // store new Penarikan
  Future<dynamic> storeAddPenarikanForEmployee(String token, String card_number,
      double amount, DateTime created_at, String description) async {
    try {
      var response = await Dio().post(employeeTambahPenarikanURL,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }),
          data: {
            'card_number': card_number,
            'amount': amount,
            'created_at': created_at.toIso8601String(),
            'description': description,
          });
      if (response.statusCode == 200 && response.data != '') {
        return response.statusCode;
      } else {
        print('Error response: ${response.data}');
        return response.data;
      }
    } on DioException catch (error) {
      print(
          'DioError: ${error.response?.data}'); // tambahkan ini untuk melihat pesan error detail
      return error;
    }
  }

  // get rekap harian for employee
  Future<dynamic> getRekapHarianForEmployee(
      String token, String filter, DateTime date) async {
    try {
      var response = await Dio().get(employeeRekapHarianURL,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }),
          queryParameters: {
            'filter': filter,
            'date': date.toIso8601String(),
          });
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Tangani berbagai jenis error
        if (e.response?.statusCode == 401) {
          // Token tidak valid
          throw Exception('Unauthorized: Token invalid or expired');
        } else if (e.response?.statusCode == 500) {
          // Error server
          throw Exception(
              'Internal Server Error: ${e.response?.data['message'] ?? 'Unknown error'}');
        }
      } else {
        // Error koneksi
        throw Exception('Connection error');
      }
    }
  }

  // get employee profil

  Future<dynamic> getEmployeeProfil(String token) async {
    try {
      var response = await Dio().get(employeeProfilURL,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json'
          }));
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // Tangani berbagai jenis error
        if (e.response?.statusCode == 401) {
          // Token tidak valid
          throw Exception('Unauthorized: Token invalid or expired');
        } else if (e.response?.statusCode == 500) {
          // Error server
          throw Exception(
              'Internal Server Error: ${e.response?.data['message'] ?? 'Unknown error'}');
        }
      } else {
        // Error koneksi
        throw Exception('Connection error');
      }
    }
  }

  // update employee profil
  Future<dynamic> updateEmployeeProfil(
      String token,
      String? name,
      String? username,
      String? email,
      String? phone_number,
      String? district,
      String? address) async {
    try {
      // Create a map that only includes the non-null field we want to update
      Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (username != null) data['username'] = username;
      if (email != null) data['email'] = email;
      if (phone_number != null) data['phone_number'] = phone_number;
      if (district != null) data['district'] = district;
      if (address != null) data['address'] = address;

      var response = await Dio().put(
        editEmployeeProfilURL,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        }),
        // Only send the field being updated
        data: data,
      );

      if (response.statusCode == 200) {
        return response.statusCode;
      } else {
        print('Error response: ${response.data}');
        return response.data['message'] ?? 'Update failed';
      }
    } on DioException catch (error) {
      print('DioError: ${error.response?.data}');
      throw Exception(
          error.response?.data?['message'] ?? 'Network error occurred');
    }
  }
}
