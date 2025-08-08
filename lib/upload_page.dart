import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:http/http.dart' as http; // Import package http
import 'batik_result_page.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _selectedImage;
  Interpreter? _interpreter;
  List<String> _labels = [];
  final int _inputSize = 224;
  bool _isLoading = false;

  final double _outputScale = 0.031607624143362045;
  final int _outputZeroPoint = 184;
  final double _confidenceThreshold = 0.2;
// Jika menggunakan Emulator Android
  final String _backendApiUrl = 'http://10.0.2.2:8000/api'; // Menggunakan IP khusus untuk emulator Android

// Jika menggunakan Perangkat Android Fisik (ganti dengan IP lokal Anda)
// final String _backendApiUrl = 'http://192.168.1.XXX:8000/api';


  final Map<String, Map<String, String>> _batikInfo = {
    'MOTIF BATIK AKA BAJELO': {
      'origin': 'Minangkabau (Sumatera Barat)',
      'philosophy': '''Motif aka bajelo mengandung arti bahwa tanaman yang memiliki akar yang saling menjalar dan menyatu.Hal ini mencerminkan adanya keselarasan dan kerja sama antar tiga tungku sajarangan pada figur di lingkungan sosial dan masyarakat adatMinangkabau, yaitu alim ulama, cerdik pandai, dan ninik mamak.Ketiga unsur inisaling terhubung dalam satu kesatuan yang harmonis,yang menciptakan kerukunandalam nagari.''',
    },
    'MOTIF BATIK AYAM KUKUAK BALENGGEK': {
      'origin': 'Solok, Sumatera Barat',
      'philosophy': '''Motif ini diciptakan oleh pemilik batik Salingka Tabek seorang entrepreneur muda generasi Milenial yaitu , Yusrizal karena terinspirasi melihat kokoh dan megahnya patung ayam yang berada di pusat Kabupaten yaitu dekat dari kantor Bupati Kabupaten Solok. Kemegahan ini mencerminkan kuatnya peran pemimpin dalam melindungi masyarakat nya.''',
    },
    'MOTIF BATIK BURUNG KUAUW': {
      'origin': 'Hutan tropis Sumatera Barat',
      'philosophy': '''Burung kuaw termasuk jenis burung langka yang hanya ada di Sumatera Barat. Burung yang memiliki bulu yang indah dan tidak kalah indah dengan burung merak.Keindahan bulu burung kuaw ini menginsiprasi pemilik rumah batik Salingka Tabek menuangkan nya dalam motif batik jenis batik tulis yang di tulis di atas secarik kain dengan bentuk yang indah. Keindahan tersebut mencerminkan filosofi bahwa keindahan akan memancarkan kebaikan, keluhuran budi dan manfaat bagi orang banyak. Keindahan akan memancarkan semangat untuk memberikan yang terbaik bagi orang banyak''',
    },
    'MOTIF BATIK BURUNG MAKAN PADI': {
      'origin': 'Solok, Sumatera barat',
      'philosophy': '''Motif burung makan padi ini mendeskripsikan burung yang menggambarkan kegembiraannya memakan padi di sawah. Buliran padi yang bernas menjadi hal yang menyenangkan bagi burung pemakan padi. Padi yang mengguning dihamparan sawah petani yang luas di deskripsikan oleh pemilik batik Salingka Tabek menjadi kekuatan hubungan antar makluk yang saling memiliki ketergantungan satu sama lain..''',
    },
    'MOTIF BATIK ITIAK PULANG PATANG': {
      'origin': 'Minangkabau, Sumatera Barat',
      'philosophy': '''Motif itiak pulang patang mendeskripsikan bahwa masyarakat Minang Kabau merupakan komunitas yang kental dengan toleransi. Ada nya toleransi yang baik ditandai dengan barisan panjang itik yang selaras dan segaris dalam mengikuti barisan yang teratur dan terpola. Hal ini juga menggambarkan bahwa dalam adat Minang Kabau pemimpin didahulukan selangkah dan ditinggikan seranting.Barisan itik juga memberikan filosofi bahwa pemimpin yang amanah akan diikuti oleh anggotanya baik dalam sikap maupun dalam perbuatan''',
    },
    'MOTIF BATIK MALABUIK PADI (TULIS)': {
      'origin': 'Solok, Sumatera barat',
      'philosophy': '''Motif batik tulis ini mendeskripsikan setelah panen padi di sawah, di lanjutkan dengan kegiatan melambuik padi (Bahasa Indonesia: memukul padi ke suatu objek untuk merontokkan padi dari tangkai/ batang padi) atau memisahkan padi dari tangkai/ batangnya dengan cara memukulkannya pada ke sebuah wadah (objek) . Kegiatan ini mengedepankan nilai-nilai gotong-royong dalam hubungan masyarakat yang sama-sama memiliki Lokasi persawahan yang berdekatan. Budaya malambuik padi memiliki local wisdom yang unik dan lestari sampai saat ini khususnya masyarakat yang berada di kabupaten di provinsi Sumatera Barat.Kekuatan dari kearifan lokal ini lah yang diusung oleh pemilik sekaligus pencipta motif.''',
    },
    'MOTIF BATIK RANCAK KABUPATEN SOLOK': {
      'origin': 'Solok, Sumatera barat',
      'philosophy': '''Keindahan alam di kabupaten Solok menginsprasi pemilik batik Salingka Tabek mendeskripsikannya dalam sentuhan tangan yang indah di atas kain polos yang berkualitas .Keindahan alam di kabupaten Solok memberikan rasa syukur dan dimanifestasikan dalam motif batik yang menggambarkan keindahan kabupaten Solok dengan kehadiran gunung Talang, Danau Di Atas dan Danau di Bawah ,Danau Singkarak serta keindahan alam lainnya yang dimiliki oleh Kabupaten Solok.''',
    },
    'MOTIF BATIK RUMAH GADANG URANG KOTO BARU': {
      'origin': 'Solok Selatan, Sumatera Barat',
      'philosophy': '''Motif batik ini menggambarkan kekhasan rumah gadang bagonjong yang dimiliki oleh nagari Koto Tuo yang dikenal dengan Nagari Seribu Rumah Gadang yang berada di Kabupaten Solok Selatan ,yaitu bertetanggaan dengan Kabupaten Solok. Nagari ini memiliki rumah gadang bagonjong yang relatif banyak jumlahnya dibanding dengan daerah/ kabupaten lain. Sehingga motif ini menjadi inspirasi baru bagi pemilik sekaligus pencipta motif ini yaitu Yusrizal.''',
    },
    'MOTIF BATIK RUMAH GADANG USANG': {
      'origin': 'Solok,Sumatera Barat',
      'philosophy': '''Motif rumah gadang usang ini mencerminkan bahwa dalam kehidupan ini akan selalu ada regenerasi. Kehadiran rumah gadang usang menjadi sejarah yang menggambarkan prototype , kehidupan dari generasi sebelumnya. Dimana menggambarkan kehidupan generasi sebelumnya yang sangat bersahaja dan ramah dengan alam sekitarnya. Rumah gadang using juga menggambarkan sebuah bukti bahwa kehidupan pernah ada di rumah tersebut yang sudah berlangsung lama dari satu generasi ke generasi berikutnya. Karena itu rumah gadang usingperlu tetap di jaga dengan tetap melestarikannya menjadi asset yang bernilai filosofi tinggi.'''
    },
    'MOTIF BATIK RUMAH GADANG': {
      'origin': 'Sumatera Barat',
      'philosophy': '''motif Rumah Gadang melambangkan kebersamaan, kekerabatan, dan nilai musyawarah dalam adat Minangkabau. Rumah Gadang tidak hanya sebagai tempat tinggal, tapi juga pusat kehidupan sosial dan adat. Dalam batik, motif ini mencerminkan jati diri, struktur matrilineal, dan penghormatan terhadap leluhur dan nilai tradisional. Setiap lekukan dan susunan motifnya menggambarkan kerukunan antar keluarga besar yang tinggal dalam satu rumah gadang serta tingginya kedudukan perempuan dalam struktur adat Minang.'''
    }
  };

  @override
  void initState() {
    super.initState();
    _loadModelAndLabels();
  }

  Future<void> _loadModelAndLabels() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/my_model_quantized_uint8.tflite');
      print("✅ Model TFLite berhasil dimuat!");

      if (_interpreter != null) {
        var inputTensor = _interpreter!.getInputTensor(0);
        print('Input Tensor Shape (dari Model): ${inputTensor.shape}');
        print('Input Tensor Type (dari Model): ${inputTensor.type}');
        print('Input Tensor Name (dari Model): ${inputTensor.name}');

        var outputTensor = _interpreter!.getOutputTensor(0);
        print('Output Tensor Shape (dari Model): ${outputTensor.shape}');
        print('Output Tensor Type (dari Model): ${outputTensor.type}');
        print('Output Tensor Name (dari Model): ${outputTensor.name}');
      }

      String labelsData = await DefaultAssetBundle.of(context).loadString('assets/labels.txt');
      _labels = labelsData.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      print("✅ Model dan label berhasil dimuat.");
    } catch (e) {
      print("❌ Gagal memuat model atau label: $e");
      if (mounted) {
        _showAlert(
          type: QuickAlertType.error,
          title: 'Error Inisialisasi',
          text: 'Gagal memuat model atau label. Aplikasi mungkin tidak berfungsi dengan benar.',
        );
      }
    }
  }

  Future<List<List<List<List<int>>>>> _preprocessImageForUint8Model(File imageFile) async {
    Uint8List imageBytes = await imageFile.readAsBytes();
    ui.Image originalImage = await decodeImageFromList(imageBytes);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final srcRect = Rect.fromLTWH(0, 0, originalImage.width.toDouble(), originalImage.height.toDouble());
    final dstRect = Rect.fromLTWH(0, 0, _inputSize.toDouble(), _inputSize.toDouble());

    canvas.drawImageRect(originalImage, srcRect, dstRect, Paint());
    final img = await recorder.endRecording().toImage(_inputSize, _inputSize);
    final ByteData? byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    final Uint8List rgbaBytes = byteData!.buffer.asUint8List();

    List<List<List<List<int>>>> input = List.generate(
      1,
          (i) => List.generate(
        _inputSize,
            (j) => List.generate(
          _inputSize,
              (k) => List.generate(
            3,
                (l) => 0,
          ),
        ),
      ),
    );

    for (int i = 0; i < _inputSize; i++) {
      for (int j = 0; j < _inputSize; j++) {
        int index = (i * _inputSize + j) * 4;
        final r = rgbaBytes[index];
        final g = rgbaBytes[index + 1];
        final b = rgbaBytes[index + 2];

        input[0][i][j][0] = r;
        input[0][i][j][1] = g;
        input[0][i][j][2] = b;
      }
    }

    return input;
  }

  // Tambahkan fungsi baru untuk mengirim data ke backend
  Future<void> _sendToBackend({
    required bool isBatik,
    String? batikName,
    String? batikOrigin,
    String? batikPhilosophy,
    double? confidence,
  }) async {
    if (_selectedImage == null) return;

    final uri = Uri.parse('$_backendApiUrl/http://10.0.2.2:8000/api/upload-image');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));
    request.fields['is_batik'] = isBatik.toString();

    if (isBatik) {
      request.fields['batik_name'] = batikName!;
      request.fields['batik_origin'] = batikOrigin!;
      request.fields['batik_philosophy'] = batikPhilosophy!;
      request.fields['confidence'] = confidence.toString();
    } else {
      // Kirim data kosong jika bukan batik
      request.fields['batik_name'] = '';
      request.fields['batik_origin'] = '';
      request.fields['batik_philosophy'] = 'Gambar bukan motif batik.';
      request.fields['confidence'] = '0.0';
    }

    _showAlert(
      type: QuickAlertType.loading,
      title: 'Mengunggah Data',
      text: 'Mengirim gambar dan hasil prediksi ke server...',
      autoCloseDuration: null,
    );

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (mounted) {
        Navigator.of(context).pop();
        if (response.statusCode == 201) {
          _showAlert(
            type: QuickAlertType.success,
            title: 'Berhasil',
            text: 'Gambar dan data berhasil diunggah ke server!',
            autoCloseDuration: const Duration(seconds: 2),
          );
        } else {
          _showAlert(
            type: QuickAlertType.error,
            title: 'Error Unggah',
            text: 'Gagal mengunggah gambar. Status: ${response.statusCode}. Respon: $responseBody',
          );
          print('❌ Error mengunggah: ${response.statusCode}, Body: $responseBody');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _showAlert(
          type: QuickAlertType.error,
          title: 'Error Koneksi',
          text: 'Gagal terhubung ke server: $e',
        );
      }
      print('❌ Error koneksi: $e');
    }
  }


  Future<void> _predictImage() async {
    if (_selectedImage == null || _interpreter == null || _labels.isEmpty || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _showAlert(
      type: QuickAlertType.loading,
      title: 'Memprediksi',
      text: 'Menganalisis gambar batik...',
      autoCloseDuration: null,
    );

    try {
      final List<List<List<List<int>>>> inputData = await _preprocessImageForUint8Model(_selectedImage!);
      var outputTensor = _interpreter!.getOutputTensor(0);
      var outputShape = outputTensor.shape;
      var output = Uint8List(outputShape.reduce((a, b) => a * b)).reshape(outputShape);

      _interpreter!.run(inputData, output);

      final List<double> probabilities = [];
      for (int i = 0; i < output[0].length; i++) {
        probabilities.add((output[0][i] - _outputZeroPoint) * _outputScale);
      }

      final Map<String, double> predictionMap = {};
      for (int i = 0; i < _labels.length; i++) {
        predictionMap[_labels[i]] = probabilities[i];
      }

      final sortedPredictions = predictionMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topPrediction = sortedPredictions.first;

      if (topPrediction.value < _confidenceThreshold || !_batikInfo.containsKey(topPrediction.key)) {
        if (mounted) {
          Navigator.of(context).pop();
          _showAlert(
            type: QuickAlertType.warning,
            title: 'Batik Tidak Dikenali',
            text: 'Kami tidak dapat mengidentifikasi motif batik atau motif tidak tersedia dalam database kami. Mohon coba gambar lain.',
          );
          // Panggil _sendToBackend untuk kasus non-batik
          _sendToBackend(isBatik: false);
        }
      } else {
        final double batikConfidence = topPrediction.value;
        // Batasi nilai kepercayaan agar tidak melebihi 100% (1.0).
        final double cappedConfidence = batikConfidence > 1.0 ? 1.0 : batikConfidence;
        final String batikOrigin = _batikInfo[topPrediction.key]?['origin'] ?? 'Tidak diketahui';
        final String batikPhilosophy = _batikInfo[topPrediction.key]?['philosophy'] ?? 'Filosofi tidak tersedia.';

        // Panggil _sendToBackend untuk kasus gambar batik
        await _sendToBackend(
          isBatik: true,
          batikName: topPrediction.key,
          batikOrigin: batikOrigin,
          batikPhilosophy: batikPhilosophy,
          confidence: cappedConfidence,
        );

        if (mounted) {
          // Navigasi ke halaman hasil setelah pengiriman ke backend berhasil
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BatikResultPage(
                uploadedImage: _selectedImage,
                batikName: topPrediction.key,
                batikConfidence: cappedConfidence,
                batikOrigin: batikOrigin,
                batikPhilosophy: batikPhilosophy,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _showAlert(
          type: QuickAlertType.error,
          title: 'Error Prediksi',
          text: 'Gagal memprediksi gambar: $e',
        );
      }
      print('❌ Error saat prediksi: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
      if (mounted) {
        _showAlert(
          type: QuickAlertType.success,
          title: 'Gambar Dipilih',
          text: 'Gambar berhasil dipilih!',
          autoCloseDuration: const Duration(seconds: 2),
        );
      }
    }
  }

  void _showAlert({
    required QuickAlertType type,
    required String title,
    required String text,
    Duration? autoCloseDuration,
  }) {
    if (!mounted) return;
    QuickAlert.show(
      context: context,
      type: type,
      title: title,
      text: text,
      autoCloseDuration: autoCloseDuration,
      backgroundColor: const Color(0xFFEAE3D6),
      titleColor: Colors.black,
      textColor: Colors.black,
      confirmBtnColor: const Color(0xFF8B4513),
      confirmBtnTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _deleteImage() {
    setState(() => _selectedImage = null);
    if (mounted) {
      _showAlert(
        type: QuickAlertType.info,
        title: 'Gambar Dihapus',
        text: 'Gambar telah dihapus dari pratinjau.',
        autoCloseDuration: const Duration(seconds: 2),
      );
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background1.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey,
                child: const Center(
                  child: Text(
                    'Background image not found',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (BuildContext bc) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFEAE3D6),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Wrap(
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Pilih dari Galeri'),
                                onTap: () {
                                  Navigator.pop(bc);
                                  _pickImage(ImageSource.gallery);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text('Ambil dari Kamera'),
                                onTap: () {
                                  Navigator.pop(bc);
                                  _pickImage(ImageSource.camera);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAE3D6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black54, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                        : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate,
                            size: 80, color: Colors.black54),
                        SizedBox(height: 10),
                        Text(
                          "Ketuk untuk Memilih Gambar",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: (_selectedImage != null && !_isLoading && _interpreter != null && _labels.isNotEmpty)
                      ? _predictImage
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text(
                    "UPLOAD & PREDIKSI",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                if (_selectedImage != null)
                  ElevatedButton(
                    onPressed: _isLoading ? null : _deleteImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "HAPUS GAMBAR",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}