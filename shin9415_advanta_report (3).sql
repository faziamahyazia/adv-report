-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Mar 09, 2026 at 08:44 PM
-- Server version: 10.11.16-MariaDB-cll-lve
-- PHP Version: 8.4.18

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `shin9415_advanta_report`
--

-- --------------------------------------------------------

--
-- Table structure for table `activities`
--

CREATE TABLE `activities` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `type_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED DEFAULT NULL,
  `date` date NOT NULL,
  `cost` decimal(10,2) NOT NULL DEFAULT 0.00,
  `location` varchar(500) DEFAULT NULL,
  `latlong` varchar(100) DEFAULT NULL,
  `image_path` varchar(500) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `responded_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `responded_datetime` datetime DEFAULT NULL,
  `status` enum('approved','rejected','not_responded') NOT NULL DEFAULT 'not_responded',
  `created_datetime` datetime DEFAULT NULL,
  `updated_datetime` datetime DEFAULT NULL,
  `created_by_uid` bigint(20) UNSIGNED DEFAULT NULL,
  `updated_by_uid` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `activities`
--

INSERT INTO `activities` (`id`, `user_id`, `type_id`, `product_id`, `date`, `cost`, `location`, `latlong`, `image_path`, `notes`, `responded_by_id`, `responded_datetime`, `status`, `created_datetime`, `updated_datetime`, `created_by_uid`, `updated_by_uid`) VALUES
(3, 8, 1, NULL, '2025-07-01', 200000.00, 'Tanjungsiang, Subang', '', 'uploads/1752462570_PhotoGrid_Plus_1751349220175.jpg', 'Kios Tani Raharja (Pak H Iwan)', 9, '2025-07-14 14:24:57', 'approved', '2025-07-14 10:09:30', '2025-07-14 14:24:57', 8, 9),
(4, 8, 2, NULL, '2025-07-04', 250000.00, 'Ciater, Subang', '', 'uploads/1752463035_20250622_123521.jpg', 'Pengenalan all produk Advanta. Fokus Produk Jagung Madu-59, Tomat Nona 23 F1, Cabai Rawit Shima dan Timun Lavanta bersama Mitra Petani Kang Ujang.', 9, '2025-07-14 14:24:47', 'approved', '2025-07-14 10:17:16', '2025-07-14 14:24:47', 8, 9),
(5, 8, 2, NULL, '2025-07-04', 250000.00, 'Ciater, Subang', '', 'uploads/1752463151_20250630_153531.jpg', 'Pengenalan all produk Advanta. Fokus Produk Jagung Madu-59, Tomat Nona 23 F1, Cabai Rawit Shima dan Timun Lavanta bersama Mitra Petani Pak Mantri Andi.', 9, '2025-07-14 14:23:08', 'approved', '2025-07-14 10:19:11', '2025-07-14 14:23:08', 8, 9),
(6, 6, 1, NULL, '2025-07-01', 200000.00, 'Ds. Cipulus Kec. Cikijing Kab. Majalengka', '', 'uploads/1752463190_IMG-20250714-WA0016.jpg', '', 2, '2025-07-14 14:32:46', 'approved', '2025-07-14 10:19:51', '2025-07-14 14:32:46', 6, 2),
(7, 8, 3, NULL, '2025-07-07', 750000.00, 'Ciater, Subang', '', 'uploads/1752463324_PhotoGrid_Plus_1751874744262.jpg', 'Melihat Hasil Panen Jagung Manis Madu-59 F1 dan pengenalan all produk Advanta. Fokus Produk Timun Lavanta, Jagung Madu-59, Tomat Nona 23 F1 dan Cabai Rawit Shima bersama Mitra Petani Pak Unem.', 9, '2025-07-14 14:22:42', 'approved', '2025-07-14 10:22:04', '2025-07-14 14:22:42', 8, 9),
(8, 6, 2, NULL, '2025-07-02', 250000.00, 'Ds. Cikandang Kec. Luragung Kab. Kuningan', '', 'uploads/1752463386_IMG-20250714-WA0018.jpg', '', 2, '2025-07-14 14:32:39', 'approved', '2025-07-14 10:23:07', '2025-07-14 14:32:39', 6, 2),
(9, 8, 3, NULL, '2025-07-03', 750000.00, 'Ciater, Subang', '', 'uploads/1752463454_20250703_161222.jpg', 'Melihat Hasil Panen Timun Lavanta dan pengenalan all produk Advanta. Fokus Produk Timun Lavanta, Jagung Madu-59, Tomat Nona 23 F1 dan Cabai Rawit Shima bersama Mitra Petani Kang Elan.', 9, '2025-07-14 14:22:17', 'approved', '2025-07-14 10:24:15', '2025-07-14 14:22:17', 8, 9),
(10, 6, 3, NULL, '2025-07-04', 750000.00, 'Ds. Cikandang Kec. Luragung Kab. Kuningan', '', 'uploads/1752465018_IMG-20250714-WA0017.jpg', '', 2, '2025-07-14 14:32:32', 'approved', '2025-07-14 10:50:18', '2025-07-14 14:32:32', 6, 2),
(11, 6, 2, NULL, '2025-07-07', 300000.00, 'Ds. Sukadana Kec. Argapura Kab. Majalengka', '', 'uploads/1752465093_IMG-20250714-WA0019.jpg', '', 2, '2025-07-14 14:32:26', 'approved', '2025-07-14 10:51:33', '2025-07-14 14:32:26', 6, 2),
(12, 5, 2, NULL, '2025-07-14', 250000.00, 'Pabedilan', '', 'uploads/1752479300_IMG-20250704-WA0017(2).jpg', 'Farmer meteeng bersama petani binaan pak syarip sambil melihat tanaman timun lavanta sekaligus ajak untuk penanaman diwilayah pabedilan cirebon dan kawal tanam Lilac 4 bungkus dan madu 1 bungkus dipabedilan', 9, '2025-07-14 17:37:40', 'approved', '2025-07-14 14:48:20', '2025-07-14 17:37:40', 5, 9),
(13, 5, 1, NULL, '2025-07-02', 200000.00, 'Sindanglaut,Cirebon', '', 'uploads/1752479543_IMG-20250702-WA0019.jpg', 'One day promotion show produk advanta benih jagung madu, timun lavanta, timun Gogor, tomat nona, cabe Shima dan Paria Beijing dikios sumber tani Sindanglaut, Cirebon 🥒🌽🍅🌶️.Sold 1 pcs tomat nona, 2 pcs lavanta, 2 pcs Shima', 9, '2025-07-14 17:33:25', 'approved', '2025-07-14 14:52:24', '2025-07-14 17:50:50', 5, 5),
(14, 7, 3, NULL, '2025-07-01', 750000.00, 'Panyingkiran', '-6.7870852,108.290971', 'uploads/1752500366_1000430650.jpg', 'Alhamdulillah FT / Stuba lihat performa paria BEIJING bersama mitra petani kios Cahayatani \r\nDi lahan pak tata umur 62hst\r\nPetikan ke 8\r\nPopulasi tanaman 500 tanaman petikan pertama 10kg, ke2 25, ke3 45, ke4 65, ke5 65, ke7 57, ke8 64 \r\nSold out 6iner paria B', 2, '2025-07-15 05:57:15', 'approved', '2025-07-14 20:39:26', '2025-07-15 05:57:15', 7, 2),
(15, 7, 4, NULL, '2025-07-03', 4125000.00, 'Karang anyar', '-6.7870852,108.290971', 'uploads/1752500460_1000436998.jpg', 'Alhamdulillah lancar acara Farmer Field Day (FFD) Jagung Manis Madu 59 F1 bersama petani Ds. Karang anyar Kec. Dawuan Majalengka \r\nPersiapan tanam kembali untuk lahan 2bau\r\n🌽🌽🌽\r\nTerimakasih support dari BS kang @⁨Pp ADV Iing Mubarok⁩ dan mas @⁨Pp ADV Fatu', 2, '2025-07-15 05:56:54', 'approved', '2025-07-14 20:41:00', '2025-07-15 05:56:54', 7, 2),
(16, 7, 2, NULL, '2025-07-07', 250000.00, 'Gadel', '-6.7870852,108.290971', 'uploads/1752500572_1000411702.jpg', 'Farmers Meeting (FM) pengenalan produk advanta bersama petani palawija DS gadel indramayu \r\n potensi lavanta, Beijing, kacang panjang herra\r\n(Bos Asno,Ikin, h.suparna)', 2, '2025-07-15 05:56:16', 'approved', '2025-07-14 20:42:53', '2025-07-29 13:59:30', 7, 9),
(17, 7, 3, NULL, '2025-07-15', 750000.00, 'Ligung', '', 'uploads/1752568813_1000453958.jpg', 'Field Trip (FT) Jagun ketan Lilac di lahan pak Maman umur 62hst \r\nbersama petani Binaan pak Taspi dan kios Sinartani, respon baik terhadap ketahanan penyakit, tongkol besar dan rasa pulen, siap menanam untuk musim selanjutnya 3box\r\n🌽🌽🌽🌽\r\nLigung', 2, '2025-07-15 16:11:39', 'approved', '2025-07-15 15:40:14', '2025-07-15 16:11:39', 7, 2),
(18, 5, 4, NULL, '2025-07-15', 4279500.00, 'Wanasaba,Talun,Cirebon', '', 'uploads/1752665869_IMG-20250715-WA0060.jpg', 'Alhamdulillah lancar acara Farmer Field Day (FFD) Jagung Manis Madu 59 F1 bersama petani Ds.wanasaba Kec. Talun, kab.cirebon dan \r\nPersiapan tanam kembali untuk lahan 2 ha\r\nDilahan pak Adi, sold 1 dus jagung madu🌽🌽🌽\r\nTerimakasih support dari SA pak @⁨Mas', 2, '2025-07-16 19:00:59', 'approved', '2025-07-16 18:37:50', '2025-07-16 19:00:59', 5, 2),
(19, 5, 5, NULL, '2025-07-16', 0.00, 'Cangkring,Cirebon', '', 'uploads/1752665984_IMG-20250716-WA0032.jpg', 'Visit kios rizkio tani display jagung manis madu dan ajak untuk tanam kembali kepetani binaannya dan sekaligus cek stok lavanta dan Beijing dicangkring Cirebon', 2, '2025-07-16 19:00:43', 'approved', '2025-07-16 18:39:45', '2025-07-16 19:00:43', 5, 2),
(20, 5, 5, NULL, '2025-07-16', 0.00, 'Matanghaji, cirebon', '', 'uploads/1752666101_IMG-20250716-WA0008.jpg', 'Visit kios umi tani display hasil panen jagung manis madu dan persiapan order jagung manis madu kembali dimatanghaji cirebon', 2, '2025-07-16 19:00:39', 'approved', '2025-07-16 18:41:41', '2025-07-16 19:00:39', 5, 2),
(21, 5, 5, NULL, '2025-07-02', 0.00, 'Sindanglaut, cirebon', '', 'uploads/1752666244_IMG-20250702-WA0032.jpg', 'Display timun lavanta kios sumber tani sindanglaut', 2, '2025-07-16 19:00:35', 'approved', '2025-07-16 18:44:04', '2025-07-16 19:00:35', 5, 2),
(22, 5, 5, NULL, '2025-07-01', 0.00, 'Matanghaji, cirebon', '', 'uploads/1752666324_IMG-20250701-WA0035.jpg', 'Display timun lavanta di kios umi tani', 2, '2025-07-16 19:00:28', 'approved', '2025-07-16 18:45:24', '2025-07-16 19:00:28', 5, 2),
(23, 5, 5, NULL, '2025-07-01', 0.00, 'Cangkring, cirebon', '', 'uploads/1752666372_IMG-20250701-WA0019.jpg', 'Visit kios riskio tani cek stok benih lavanta dan display hasil panenan timun lavanta dicirebon', 2, '2025-07-16 19:00:21', 'approved', '2025-07-16 18:46:12', '2025-07-16 19:00:21', 5, 2),
(24, 5, 3, NULL, '2025-07-14', 750000.00, 'Kalimukti, pabedilan', '', 'uploads/1752726790_IMG-20250714-WA0105.jpg', 'Field trip bersama petani binaan pak Arifin bersama petani jagung manis dari dukuhwidara menuju kalimukti sekaligus melihat performa jagung manis madudan persiapan penanaman jagung madu 5 pcs dan Lilac5 pcs dipabedilan cirebon', 2, '2025-07-17 11:53:23', 'approved', '2025-07-17 11:33:10', '2025-07-17 11:53:23', 5, 2),
(25, 7, 1, NULL, '2025-07-17', 200000.00, 'Kios cahayatani', '', 'uploads/1752727094_1000456378.jpg', 'ODP KIOS CAHAYATANI\r\n🌽🥒🌶️🫘🌽\r\nPanyingkiran', 2, '2025-07-17 11:53:39', 'approved', '2025-07-17 11:38:14', '2025-07-17 11:53:39', 7, 2),
(26, 8, 1, NULL, '2025-07-18', 200000.00, 'Tanjungsiang, Subang', '', 'uploads/1752810529_PhotoGrid_Plus_1752810216240.jpg', 'ODP Kios Barokah Tani (Bu Hj Aneng)\r\nPengenalan produk Advanta ke petani dan support penyerapan jagung manis madu-59 F1 di kios.\r\nTanjungsiang, Subang.', 2, '2025-07-18 11:57:50', 'approved', '2025-07-18 10:48:49', '2025-07-18 11:57:50', 8, 2),
(27, 5, 7, NULL, '2025-07-18', 0.00, 'Sindanglaut kios tani makmur', '', 'uploads/1752824344_IMG20250718143640.jpg', 'Pasang Baner jagung madu advanta dikios tani makmur', 2, '2025-07-18 15:04:02', 'approved', '2025-07-18 14:39:05', '2025-07-18 15:04:02', 5, 2),
(28, 5, 7, NULL, '2025-07-18', 0.00, 'Cangkring kios rizkio tani', '', 'uploads/1752825415_IMG-20240928-WA0020.jpg', '', 2, '2025-07-18 15:03:51', 'approved', '2025-07-18 14:56:55', '2025-07-18 15:03:51', 5, 2),
(29, 5, 2, NULL, '2025-07-18', 250000.00, 'Gebang,Cirebon', '', 'uploads/1752825721_IMG-20250716-WA0053(1).jpg', 'Farmer meteeng sekaligus melihat hasil panenan jagung manis madu dan hasil petikan timun lavanta diwilayah gebang bersama binaan pak Mardi sekaligus ajak tanam jagung madu kembali para petani gebang, Cirebon', 2, '2025-07-18 15:03:38', 'approved', '2025-07-18 15:02:01', '2025-07-18 15:03:38', 5, 2),
(30, 7, 2, NULL, '2025-07-18', 250000.00, '', '-6.6758935,108.3006268', 'uploads/1752830370_1000453818.jpg', 'Farmer Meeting (FM)\r\nPengenalan produk advanta bersama petani Ds pancaksuji. Kec sumberjaya\r\nPokus produk Madu,Lilac,lavanta,KC.herra Sekaligus kunjungan program kerja dalam ketahanan pangan KKN Mahasiswa IPB\r\n🌽🌶️🥒🫘', 2, '2025-07-19 10:56:48', 'approved', '2025-07-18 16:19:30', '2025-07-29 13:59:13', 7, 9),
(31, 5, 7, NULL, '2025-07-20', 0.00, '', '', 'uploads/1753007112_IMG-20240625-WA0002.jpg', 'Branding pemasangan baner dikios umi tani', 2, '2025-07-22 11:39:12', 'approved', '2025-07-20 17:25:12', '2025-07-22 11:39:12', 5, 2),
(32, 8, 7, NULL, '2025-07-21', 142500.00, 'Wanayasa, Purwakarta', '', 'uploads/1753087694_20250721_153909.jpg', 'Kios Fajar Tani Mandiri', 2, '2025-07-21 15:49:19', 'approved', '2025-07-21 15:48:14', '2025-07-21 15:49:19', 8, 2),
(33, 8, 7, NULL, '2025-07-22', 142500.00, 'Ciater, Subang', '', 'uploads/1753167846_20250722_135706.jpg', 'Kios Bumi Hijau Makmur', 2, '2025-07-22 15:31:06', 'approved', '2025-07-22 14:04:06', '2025-07-22 15:31:06', 8, 2),
(34, 5, 3, NULL, '2025-07-22', 660000.00, 'Hulubanteng,Cirebon', '-6.6904989,108.4964155', 'uploads/1753169050_IMG-20250722-WA0045.jpg', 'studibanding dilahan pak wirto sekaligus melihat performa jagung manis madu bersama binaan bandar pak haji darga dan bandar pak carwan diwilayah hulubanteng sekaligus mencari spot lahan yang cocok untuk ditanam L7 dan persiapan tanam jagung madu kembali d', 2, '2025-07-22 15:31:30', 'approved', '2025-07-22 14:24:11', '2025-07-22 15:31:30', 5, 2),
(35, 5, 2, NULL, '2025-07-23', 250000.00, 'Pabedilan', '-6.6928775,108.4978176', 'uploads/1753277741_IMG-20250723-WA0016.jpg', 'Farmer meteeng mengenalkan benih advanta jagung madu, Lilac, Reva, Anara dan h72 dikrlompok tani jagung pabedilan dilahan pak dastam sekaligus mengajak tanam jagung advanta , pabedilan. Cirebon', 2, '2025-07-23 21:57:43', 'approved', '2025-07-23 20:35:42', '2025-07-23 21:57:43', 5, 2),
(36, 6, 1, NULL, '2025-07-25', 200000.00, 'Kios Sukatani Sae', '', 'uploads/1753413428_IMG_1035.jpeg', '', 2, '2025-07-25 10:33:40', 'approved', '2025-07-25 10:17:10', '2025-07-25 10:33:40', 6, 2),
(37, 8, 7, NULL, '2025-07-25', 142500.00, 'Tanjungsiang, Subang', '-6.7307199,107.8007315', 'uploads/1753424846_20250725_132312.jpg', 'Kios Tani Raharja', 2, '2025-07-25 13:40:47', 'approved', '2025-07-25 13:27:27', '2025-07-25 13:40:47', 8, 2),
(39, 7, 2, NULL, '2025-07-24', 250000.00, 'Jatitujuh', '-6.7871266,108.2909879', 'uploads/1753500682_1000455967.jpg', 'FM bersama petani desa Wanasalam\r\nBersama petani binaan kios sobatani\r\n🌽🥒🫘\r\nJatitujuh', 2, '2025-07-26 11:29:07', 'approved', '2025-07-26 10:31:23', '2025-07-29 13:58:53', 7, 9),
(40, 7, 5, NULL, '2025-07-26', 0.00, 'Kios sobatani', '-6.7870214,108.2909874', 'uploads/1753500764_1000463234.jpg', 'Visit kios sobatani\r\nPengenalan hasil panenan jagung ketan Lilac serta display buah segar\r\nOrder 2 box jagung Lilac\r\nJatitujuh', 2, '2025-07-26 11:28:56', 'approved', '2025-07-26 10:32:45', '2025-07-26 11:28:56', 7, 2),
(41, 5, 8, NULL, '2025-07-26', 0.00, '', '-6.7795943,108.6145936', 'uploads/1753510773_IMG20250725090949.jpg', 'Dititipkan Dimas iing', 2, '2025-07-26 18:13:33', 'approved', '2025-07-26 13:19:34', '2025-07-26 18:13:33', 5, 2),
(42, 6, 8, NULL, '2025-07-29', 0.00, 'Kuningan', '-7.0007435,108.4539494', NULL, '', 9, '2025-07-29 22:02:41', 'approved', '2025-07-29 19:45:05', '2025-07-29 22:02:41', 6, 9),
(43, 8, 8, NULL, '2025-07-29', 0.00, 'Subang', '-6.73941,107.670605', NULL, 'FM 2 = 400.000\r\nFT 2 = 1.430.000\r\nODP 2 = 400.000\r\nKebutuhan Branding = 487.500\r\nTiket Kereta = 985.000', 9, '2025-07-30 11:56:55', 'approved', '2025-07-29 21:15:05', '2025-07-30 11:56:55', 8, 9),
(44, 6, 5, NULL, '2025-07-31', 0.00, 'Kios Agro Tani', '', 'uploads/1753943634_IMG_1251.jpeg', '', 9, '2025-07-31 18:40:39', 'approved', '2025-07-31 13:33:55', '2025-07-31 18:40:39', 6, 9),
(45, 6, 5, NULL, '2025-07-31', 0.00, 'Kios Aneka Jaya Tani', '-6.938865657885525,108.30515517334787', 'uploads/1753948737_829347b4-e8a1-4319-b682-d38774ab0601.jpeg', '', 9, '2025-07-31 18:40:42', 'approved', '2025-07-31 14:58:57', '2025-07-31 18:40:42', 6, 9),
(46, 7, 8, NULL, '2025-07-31', 0.00, '', '', NULL, '', 9, '2025-07-31 21:40:29', 'approved', '2025-07-31 21:40:20', '2025-07-31 21:40:29', 9, 9),
(47, 6, 2, NULL, '2025-08-01', 250000.00, 'Ds. Haurgeulis Kec. Bantarujeg Kab. Majalengka', '', 'uploads/1754016981_C4D1C085-3087-4813-A6A9-36652FFFD023.jpeg', 'FM pengenalan hasil panenan Madu 59 F1 bersama petani binaan Kios Agro Tani', 2, '2025-08-01 16:16:00', 'approved', '2025-08-01 09:56:21', '2025-08-01 16:16:00', 6, 2),
(48, 7, 3, NULL, '2025-08-01', 750000.00, 'Banggalah Kertajati', '-6.8014515,108.1790261', 'uploads/1754036813_IMG_20250725_115405.jpg', 'Field triptimun lavanta dan kacang panjang herra\r\nBersama petani binaan pakNoto dan aef di lahan pakOtong dan pak sule \r\nRespon petani terhadap \r\nLavanta\r\nBuah di terima pasar\r\nKp.herra\r\nBuah di terima pasar\r\nDan ketahan terhadap virusGemini amanBanggalakertajat', 2, '2025-08-01 16:16:19', 'approved', '2025-08-01 15:26:53', '2025-08-01 16:16:19', 7, 2),
(49, 7, 3, NULL, '2025-08-03', 750000.00, 'Parapatan sumberjaya', '', 'uploads/1754215357_1000468122.jpg', 'Alhamdulillah FT / Stuba lihat  perfom jagung ketan LILAC bersama petani DS.parapatan sumberjaya mitra petani pak taspi dan sirod\r\nDi lahan pak Maman umur 65hst\r\nPersiapan tanam kembaliLilac 4box di petani mitra pak taspi\r\n🌽🌽🌽\r\nSumberjaya', 2, '2025-08-05 08:00:57', 'approved', '2025-08-03 17:02:37', '2025-08-05 08:00:57', 7, 2),
(50, 7, 5, NULL, '2025-08-03', 0.00, 'Kios cahayatani', '', 'uploads/1754225298_1000480224.jpg', '', 9, '2025-08-04 11:48:57', 'approved', '2025-08-03 19:48:18', '2025-08-04 11:48:57', 7, 9),
(51, 5, 3, NULL, '2025-08-03', 750000.00, 'Waled cirebon', '-6.6913417,108.4993834', 'uploads/1754289706_IMG-20250729-WA0052(1).jpg', 'Fieldtrip bersama bandar pak kurman dan binaan pak haji darga sekaligus pantau hasil panenan jagung madu 7 bungkus dan sample Reva 1 pcs. Sekaligus kawal kelapak pak haji Oka, Alhamdulillah respon bagus dan kata petani walaupun dipanen lama sampe umur 76', 9, '2025-08-04 16:34:30', 'approved', '2025-08-04 13:41:46', '2025-08-04 16:34:30', 5, 9),
(52, 5, 3, NULL, '2025-08-04', 720000.00, 'Megu, cirebon', '-6.6913417,108.4993834', 'uploads/1754289935_IMG-20250728-WA0013(1).jpg', 'Fieldtrip panen jagung Lilac Alhamdulillah respon petani bagus dan siap tanam kembali dan petani kunci ajak binaannya untuk tanaman jagung Lilac dan madu. Sekaligus panen jagung madu untuk dan mengenalkan kepetani binaannya sekaligus tanam Reva 9 +Lilac 9', 9, '2025-08-04 16:34:26', 'approved', '2025-08-04 13:45:36', '2025-08-04 16:34:26', 5, 9),
(53, 5, 2, NULL, '2025-08-01', 250000.00, 'Pabedilan,Cirebon', '-6.6911086,108.4971574', 'uploads/1754290789_IMG-20250729-WA0038(2).jpg', 'Farmer meteeng bersama binaan mas Basyar mengenalkan jagung Reva sekaligus panen jagung Lilac Alhamdulillah respon petani diwilayah sini tertarik tanam jagung Lilac. menunggu pengairan lancar akan digarap penanaman jagung Lilac dibinaan petani mas Basyar', 2, '2025-08-05 08:01:05', 'approved', '2025-08-04 13:59:50', '2025-08-05 08:01:05', 5, 2),
(54, 6, 7, NULL, '2025-08-06', 0.00, 'Kios Shabira Tani', '-6.965230593153873,108.38197269065219', 'uploads/1754443249_IMG_1380.jpeg', '', 2, '2025-08-06 09:20:32', 'approved', '2025-08-06 08:20:49', '2025-08-06 09:20:32', 6, 2),
(55, 8, 3, NULL, '2025-08-06', 700000.00, 'Darangdan, Purwakarta', '', 'uploads/1754460587_PhotoGrid_Plus_1754460421395.jpg', 'Study Banding / Field Trip (FT)\r\nMelihat Hasil Panen Jagung Manis Madu-59 F1 dan pengenalan all produk Advanta. Fokus Produk Timun Lavanta, Jagung Madu-59, Tomat Nona 23 F1 dan Cabai Rawit Shima bersama Mitra Petani Pak Eka\r\nKecamatan Darangdan, Purwakarta.', 9, '2025-08-06 14:43:32', 'approved', '2025-08-06 13:09:48', '2025-08-06 14:43:32', 8, 9),
(56, 5, 5, NULL, '2025-08-02', 0.00, 'Sindanglaut cirebon', '-6.6930022,108.4975606', 'uploads/1754573582_IMG-20250730-WA0008(1).jpg', 'Display hasil panenan jagung Lilac di kios tani makmur', 9, '2025-08-07 21:38:52', 'approved', '2025-08-07 20:33:02', '2025-08-07 21:38:52', 5, 9),
(57, 5, 5, NULL, '2025-08-02', 0.00, 'Cirebon', '-6.692851,108.4976875', 'uploads/1754573666_IMG-20250730-WA0012.jpg', 'Display panenan jagung Lilac dikios Diah lestari', 9, '2025-08-07 21:38:47', 'approved', '2025-08-07 20:34:27', '2025-08-07 21:38:47', 5, 9),
(58, 5, 5, NULL, '2025-08-05', 0.00, 'Matanghaji Cirebon', '-6.6928117,108.4976022', 'uploads/1754573862_IMG-20250731-WA0018.jpg', 'Display jagung Lilac dikios umitani dimatanghaji', 9, '2025-08-07 21:38:35', 'approved', '2025-08-07 20:37:42', '2025-08-07 21:38:35', 5, 9),
(59, 5, 5, NULL, '2025-08-04', 0.00, 'Waled, cirebon', '-6.6928181,108.4976053', 'uploads/1754573977_IMG-20250802-WA0043.jpg', 'Display jagung Lilac dikios berkah Mulyatani sekaligus mengirim jagung Reva dan lavanta', 9, '2025-08-07 21:38:29', 'approved', '2025-08-07 20:39:37', '2025-08-07 21:38:29', 5, 9),
(60, 5, 2, NULL, '2025-08-09', 250000.00, 'Weru, cirebon', '-6.6911086,108.4971574', 'uploads/1754798804_IMG-20250803-WA0019(3).jpg', 'Farmer meteeng sekaligus mengenalkan panenan jagung Lilac, madu dan jagung Reva dilahan mas Hadi. Persiapan lahan dan kawal penanaman Reva 5 bungkus dilahan pertama serta order Lilac  11 pcs untuk binaan mas Hadi dan binaan mas Surya diwilayah Cirebon.', 2, '2025-08-10 20:34:18', 'approved', '2025-08-10 11:06:44', '2025-08-10 20:34:18', 5, 2),
(61, 6, 7, NULL, '2025-08-11', 0.00, 'Kiya Tani', '-7.0197926071334775,108.36986026201829', 'uploads/1754875385_IMG_1485.jpeg', '', 2, '2025-08-11 12:24:08', 'approved', '2025-08-11 08:23:05', '2025-08-11 12:24:08', 6, 2),
(62, 6, 7, NULL, '2025-08-11', 0.00, 'Agro Tani', '', 'uploads/1754911761_003bb08f-acf2-44cc-b30a-bd6b1da5be2a.jpeg', '', 9, '2025-08-11 20:32:44', 'approved', '2025-08-11 18:29:21', '2025-08-11 20:32:44', 6, 9),
(63, 6, 2, NULL, '2025-08-11', 300000.00, 'Ds. Argalingga Kec. Argapura Kab. Majalengka', '', 'uploads/1754911822_IMG_1510.jpeg', '', 9, '2025-08-11 20:32:49', 'approved', '2025-08-11 18:30:22', '2025-08-11 20:32:49', 6, 9),
(64, 5, 5, NULL, '2025-08-11', 0.00, 'Sindanglaut', '-6.6946345,108.4967865', 'uploads/1754925759_IMG20250811154105.jpg', 'Display panenan jagung Lilac, reva dan madu dikios sumber tani. Respon jagung manis cocok ke madunamun respon petani lebih condong keReva jika siwilnya tidak banyak', 2, '2025-08-12 06:00:20', 'approved', '2025-08-11 22:22:39', '2025-08-12 06:00:20', 5, 2),
(65, 5, 5, NULL, '2025-08-11', 0.00, 'Sindanglaut', '-6.6916609,108.4993834', 'uploads/1754925870_IMG20250811150519.jpg', 'Sample display panenan jagung madu dan Lilac sekaligus mengenalkan hasil panenan jagung Reva dikios tani makmur sindanglaut', 2, '2025-08-12 06:00:14', 'approved', '2025-08-11 22:24:30', '2025-08-12 06:00:14', 5, 2),
(67, 7, 2, NULL, '2025-08-12', 250000.00, 'Mandala dawuan', '', 'uploads/1754996278_1000492787.jpg', 'Farmers Meeting (FM) pengenalan produk advanta bersama petani binaan kios sobatani\r\n🌽🥒🫘🌽\r\n Mandala , dawuan Majalengka', 2, '2025-08-13 08:18:23', 'approved', '2025-08-12 17:57:58', '2025-08-13 08:18:23', 7, 2),
(68, 7, 2, NULL, '2025-08-12', 300000.00, 'Ranji wetan', '', 'uploads/1755007713_1000492919.jpg', 'Farmers Meeting (FM) pengenalan produk advanta \r\nBersama minta petani bos doing palawija\r\nPotensi benih masuk \r\nLavanta,Beijing,herra,shima\r\n🌽🥒🫘🌽\r\n Ranji wetan Kasoakandel', 2, '2025-08-13 08:18:20', 'approved', '2025-08-12 21:08:33', '2025-08-13 08:18:20', 7, 2),
(69, 5, 2, NULL, '2025-08-12', 300000.00, '', '-6.6916609,108.4993834', 'uploads/1755008413_Picsart_25-08-12_12-22-31-555.jpg', 'Farmer meteeng dikelompok tani binaan pak sihab dan pak Surya dan PPL karamgsasi mengenalkan jagung Reva, madu,Lilac dan benih palawija. Sekaligus Order 30 pcs untuk penanaman Senin depan dikarangsari, cirebon', 2, '2025-08-13 08:18:14', 'approved', '2025-08-12 21:20:13', '2025-08-13 08:18:14', 5, 2),
(70, 6, 5, NULL, '2025-08-13', 0.00, 'Setia Jaya Tani', '-6.949438468292874,108.3449879474249', 'uploads/1755067301_IMG_1588.jpeg', '', 2, '2025-08-13 18:25:30', 'approved', '2025-08-13 13:41:42', '2025-08-13 18:25:30', 6, 2),
(71, 6, 5, NULL, '2025-08-13', 0.00, 'Milda Tani', '-6.949504628855006,108.359723080895', 'uploads/1755070038_IMG_1592.jpeg', '', 2, '2025-08-13 18:25:27', 'approved', '2025-08-13 14:27:19', '2025-08-13 18:25:27', 6, 2),
(72, 6, 5, NULL, '2025-08-13', 0.00, 'Cimek Tani', '-6.959232975787611,108.37721330187182', 'uploads/1755071354_IMG_1594.jpeg', '', 2, '2025-08-13 18:25:24', 'approved', '2025-08-13 14:49:15', '2025-08-13 18:25:24', 6, 2),
(74, 11, 3, NULL, '2025-08-12', 750000.00, 'Lemahduhur', '-6.8306706,107.1681789', 'uploads/1755091974_Picsart_25-08-12_14-06-15-929 (1).jpg', 'Alhamdulillah Study Banding ke lahan pa ade bersama para petani Binaan H Mus dan Kang Adul melihat perform  dan Tumbuh Kembangnya', 4, '2025-08-19 18:01:21', 'approved', '2025-08-13 20:28:31', '2025-08-19 18:01:21', 11, 4),
(75, 6, 5, NULL, '2025-08-13', 0.00, 'Andri Tani', '', 'uploads/1755096021_IMG_1596.jpeg', '', 2, '2025-08-14 10:06:56', 'approved', '2025-08-13 21:40:22', '2025-08-14 10:06:56', 6, 2),
(76, 6, 5, NULL, '2025-08-13', 0.00, 'H. Endin Tani', '', 'uploads/1755096077_IMG_1598.jpeg', '', 2, '2025-08-14 10:06:49', 'approved', '2025-08-13 21:41:18', '2025-08-14 10:06:49', 6, 2),
(77, 6, 5, NULL, '2025-08-13', 0.00, 'Shabira Tani', '', 'uploads/1755096134_IMG_1599.jpeg', '', 2, '2025-08-14 10:06:40', 'approved', '2025-08-13 21:42:15', '2025-08-14 10:06:40', 6, 2),
(78, 6, 5, NULL, '2025-08-13', 0.00, 'Mustika Mulya Tani', '', 'uploads/1755096183_IMG_1600.jpeg', '', 2, '2025-08-14 10:06:34', 'approved', '2025-08-13 21:43:04', '2025-08-14 10:06:34', 6, 2),
(79, 6, 5, NULL, '2025-08-14', 0.00, 'Mandiri Jaya Tani', '-6.935363726872445,108.4877016459267', 'uploads/1755153479_IMG_1614.jpeg', '', 2, '2025-08-14 14:40:45', 'approved', '2025-08-14 13:38:00', '2025-08-14 14:40:45', 6, 2),
(80, 6, 5, NULL, '2025-08-14', 0.00, 'Wajam Tani', '', 'uploads/1755166023_IMG_1636.jpeg', '', 2, '2025-08-14 18:02:43', 'approved', '2025-08-14 17:07:04', '2025-08-14 18:02:43', 6, 2),
(81, 7, 7, NULL, '2025-08-19', 100000.00, 'Kios sobatani', '', 'uploads/1755582067_1000502230.jpg', 'Visit kios sobat tani\r\nPasang branding kios\r\nOrder madu 3box\r\nLavanta 5iner\r\nJatitujuh', 2, '2025-08-19 18:33:16', 'approved', '2025-08-19 12:41:07', '2025-08-19 18:33:16', 7, 2),
(82, 6, 1, NULL, '2025-08-20', 200000.00, 'Nana Tani', '', 'uploads/1755659382_IMG_1762.jpeg', '', 2, '2025-08-20 12:11:48', 'approved', '2025-08-20 10:09:43', '2025-08-20 12:11:48', 6, 2),
(83, 7, 1, NULL, '2025-08-20', 200000.00, 'Kios sinartani', '', 'uploads/1755661546_1000503276.jpg', 'On Going, One Day Promo di Kios sinartani \r\n🥒🫘🌽\r\nLigung', 2, '2025-08-20 12:11:44', 'approved', '2025-08-20 10:45:46', '2025-08-20 12:11:44', 7, 2),
(84, 7, 7, NULL, '2025-08-20', 100000.00, 'Kios sinartani', '', 'uploads/1755661596_1000503282.jpg', '', 2, '2025-08-20 12:11:37', 'approved', '2025-08-20 10:46:36', '2025-08-20 12:11:37', 7, 2),
(85, 5, 7, NULL, '2025-08-20', 0.00, 'Matanghaji, cirebon', '-6.6927809,108.4975336', 'uploads/1755683184_Picsart_25-08-20_11-55-51-479.jpg', 'Branding pasang spanduk dan Baner advanta dikios umi tani', 2, '2025-08-21 07:06:50', 'approved', '2025-08-20 16:46:25', '2025-08-21 07:06:50', 5, 2),
(86, 5, 7, NULL, '2025-08-20', 0.00, 'Talun,Cirebon', '-6.6927809,108.4975336', 'uploads/1755683332_Picsart_25-08-20_15-06-52-517.jpg', 'Branding pasang spanduk jagung madu advanta dilapak jualan pak Adi supaya pengecer binannya lebih hafal dan mengenal melekat akan produk advanta', 2, '2025-08-21 07:06:40', 'approved', '2025-08-20 16:48:52', '2025-08-21 07:06:40', 5, 2),
(87, 5, 1, NULL, '2025-08-21', 200000.00, 'Karangsembung,Sindanglaut,Cirebon', '-6.8506152,108.6473747', 'uploads/1755740155_Picsart_25-08-21_08-31-44-161.jpg', 'Odp dikios Diah lestari fokus produk lavanta dan mengenalkan produk lainnya jagung manis madu, Reva, Lilac, Paria Beijing, Shima dan lainnya disindanglaut, cirebon', 2, '2025-08-21 09:52:28', 'approved', '2025-08-21 08:35:56', '2025-08-21 09:52:28', 5, 2),
(88, 5, 7, NULL, '2025-08-21', 0.00, 'Sindanglaut, karangsembung,Cirebon', '-6.8506152,108.6473747', 'uploads/1755740225_IMG20250821082328.jpg', '', 2, '2025-08-21 09:52:20', 'approved', '2025-08-21 08:37:05', '2025-08-21 09:52:20', 5, 2),
(89, 5, 7, NULL, '2025-08-21', 0.00, 'Sindanglaut,Cirebon', '-6.8506152,108.6473747', 'uploads/1755740309_IMG20250821082328.jpg', 'Branding Baner timun lavanta dikios Diah lestari Cirebon', 2, '2025-08-21 09:52:15', 'approved', '2025-08-21 08:37:59', '2025-08-21 09:52:15', 5, 2),
(90, 6, 3, NULL, '2025-08-21', 750000.00, 'Ds. Sidamulya Kec. Jalaksana Kab. Kuningan', '', 'uploads/1755749681_253CF6AE-A484-4397-A10B-552781F3CF4D.jpeg', '', 2, '2025-08-21 17:20:56', 'approved', '2025-08-21 11:14:41', '2025-08-21 17:20:56', 6, 2),
(91, 6, 5, NULL, '2025-08-21', 0.00, 'Kios Nana Tani', '-6.927815706898033,108.46463222139063', 'uploads/1755749751_IMG_1837.jpeg', '', 2, '2025-08-21 17:20:44', 'approved', '2025-08-21 11:15:52', '2025-08-21 17:20:44', 6, 2),
(92, 6, 5, NULL, '2025-08-21', 0.00, 'Kios Sri Mulya Tani', '-6.937788525747221,108.46530260005996', 'uploads/1755751141_IMG_1838.jpeg', '', 2, '2025-08-21 17:20:35', 'approved', '2025-08-21 11:39:03', '2025-08-21 17:20:35', 6, 2),
(93, 6, 5, NULL, '2025-08-21', 0.00, 'Jaya Abadi Tani', '', 'uploads/1755756271_IMG_1839.jpeg', '', 2, '2025-08-21 17:20:30', 'approved', '2025-08-21 13:04:32', '2025-08-21 17:20:30', 6, 2),
(94, 6, 5, NULL, '2025-08-21', 0.00, 'Mandiri Jaya Tani', '', 'uploads/1755756337_IMG_1841.jpeg', '', 2, '2025-08-21 17:20:38', 'approved', '2025-08-21 13:05:38', '2025-08-21 17:20:38', 6, 2),
(95, 8, 1, NULL, '2025-08-22', 200000.00, 'Ciater, Subang', '-6.737528,107.6704633', 'uploads/1755833985_PhotoGrid_Plus_1755833744576.jpg', 'ODP Kios Bumi Hijau Makmur (Kang Sandi)\r\nPengenalan produk Advanta ke petani di kios dan penyerapan produk advanta dikios.\r\nCiater, Subang.', 2, '2025-08-22 10:45:57', 'approved', '2025-08-22 10:39:45', '2025-08-22 10:45:57', 8, 2),
(96, 7, 7, NULL, '2025-08-22', 100000.00, 'Kios cahayatani', '', 'uploads/1755836202_1000506386.jpg', '', 2, '2025-08-22 15:11:25', 'approved', '2025-08-22 11:16:42', '2025-08-22 15:11:25', 7, 2),
(97, 6, 3, NULL, '2025-08-22', 750000.00, 'Ds. Argalingga Kec. Argapura Kab. Majalengka', '', 'uploads/1755851115_4D3F1FB6-240F-452D-BABE-23407AA706FA.jpeg', '', 2, '2025-08-22 20:09:10', 'approved', '2025-08-22 15:25:15', '2025-08-22 20:09:10', 6, 2),
(98, 11, 3, NULL, '2025-08-22', 750000.00, 'Cibihbul', '-6.8304548,107.1683569', 'uploads/1755852875_IMG-20250804-WA0016.jpg', 'perform Lavanta Panen ke 9 di lahan kang dede, Respon Lumayan Baik Karna Hingga panen ke-9 Buah masih panjang dan bagus, Kekurangan memang di panen-1 buah aga kurang namun alhamdulillah nyabuah d seler atw cabang lumayan cukup atas dasar pengurusan yg bag', 4, '2025-09-01 12:23:30', 'approved', '2025-08-22 15:54:36', '2025-09-01 12:23:30', 11, 4),
(99, 11, 2, NULL, '2025-08-22', 300000.00, 'Loji, Tabrik', '-6.8304489,107.1683657', 'uploads/1755852995_IMG-20250822-WA0045.jpg', 'Alhamdulillah Farmer Meeting Terlaksana Bersama Petani binaan Pa Dedi Pengembangan dan Pengenalan Produk Shima dari Advanta Sekaligus Handle  kritik dan Saran Produk Advanta (Madu dan Nona)', 4, '2025-09-01 12:23:42', 'approved', '2025-08-22 15:56:36', '2025-09-01 12:23:42', 11, 4),
(100, 8, 2, NULL, '2025-08-23', 250000.00, 'Ciater, Subang', '', 'uploads/1755930655_PhotoGrid_Plus_1755923925660.jpg', 'Farmer Meeting (FM)\r\nPengenalan produk Advanta. Fokus Produk Jagung Madu-59 F1, Cabai Rawit Shima, Tomat Nona 23 F1, dan Timun Lavanta bersama Petani binaan Pak Jali.\r\nKecamatan Ciater, Subang.', 2, '2025-08-24 05:48:16', 'approved', '2025-08-23 13:30:56', '2025-08-24 05:48:16', 8, 2),
(101, 8, 4, NULL, '2025-08-25', 6500000.00, 'Bungursari, Purwakarta', '', 'uploads/1756108971_IMG-20250825-WA0013.jpg', 'Farmer Field Day (FFD) Jagung Manis Madu-59 F1. \r\nPengenalan Produk Jagung Manis Madu-59 F1, Melihat hasil Panen dan Sharing teknis budidaya Jagung Manis Madu-59 F1 bersama Mitra Petani sekaligus Bandar Pak Asnu.', 2, '2025-08-26 07:34:57', 'approved', '2025-08-25 15:02:51', '2025-08-26 07:34:57', 8, 2),
(102, 8, 5, NULL, '2025-08-27', 0.00, 'Ciater, Subang', '', 'uploads/1756263773_20250827_100123.jpg', 'Kios Bumi Hijau Makmur', 2, '2025-08-27 12:52:23', 'approved', '2025-08-27 10:02:54', '2025-08-27 12:52:23', 8, 2),
(103, 8, 5, NULL, '2025-08-28', 0.00, 'Ciater, Subang', '-6.7374962,107.6704535', 'uploads/1756347927_20250828_092301.jpg', 'Kios Bumi Hijau Makmur', 2, '2025-08-28 15:29:03', 'approved', '2025-08-28 09:25:28', '2025-08-28 15:29:03', 8, 2),
(104, 8, 5, NULL, '2025-08-28', 0.00, 'Wanayasa, Purwakarta', '', 'uploads/1756383565_20250828_153648.jpg', 'Kios Fajar Tani Mandiri', 2, '2025-08-29 06:50:35', 'approved', '2025-08-28 19:19:26', '2025-08-29 06:50:35', 8, 2),
(105, 6, 4, NULL, '2025-08-29', 0.00, 'Ds. Sukamukti Kec. Jalaksana Kab. Kuningan', '', 'uploads/1756510177_D6702FEB-B997-4903-A928-A5FCB80B3F37.jpeg', '', 2, '2025-08-30 09:36:49', 'approved', '2025-08-30 06:29:37', '2025-08-30 09:36:49', 6, 2),
(106, 6, 8, NULL, '2025-08-31', 0.00, '', '-7.0007368,108.4539542', NULL, '', 2, '2025-08-31 19:34:48', 'approved', '2025-08-31 19:30:40', '2025-08-31 19:34:48', 6, 2),
(107, 8, 8, NULL, '2025-08-31', 0.00, 'Bandung', '', NULL, '', 2, '2025-08-31 19:34:58', 'approved', '2025-08-31 19:31:36', '2025-08-31 19:34:58', 8, 2),
(108, 5, 8, NULL, '2025-08-31', 0.00, 'Cirebon', '-6.6916609,108.4993834', 'uploads/1756645307_IMG20250831200019.jpg', 'Berkas, absen dan dokumen kegiatan bulan Agustus 2025', 2, '2025-08-31 20:11:30', 'approved', '2025-08-31 20:01:48', '2025-08-31 20:11:30', 5, 2),
(109, 7, 8, NULL, '2025-08-31', 0.00, '', '', 'uploads/1756647206_1000518947.jpg', 'Kegiatan bulanAgustus', 2, '2025-08-31 20:35:03', 'approved', '2025-08-31 20:33:26', '2025-08-31 20:35:03', 7, 2),
(110, 5, 2, NULL, '2025-09-01', 250000.00, 'Jatirenggang,Cirebon', '-6.8998492,108.7115534', 'uploads/1756704382_Picsart_25-09-01_09-53-17-975.jpg', 'Farmer meteeng bersama petani binaan kios berkah Mulya tani kawal panenan jagung Reva advanta dan penanaman kembali jagung manis madu 4 bungkus dijatirenggang Cirebon', 9, '2025-09-01 20:49:08', 'approved', '2025-09-01 12:26:23', '2025-09-01 20:49:08', 5, 9),
(111, 5, 7, NULL, '2025-09-01', 0.00, 'Waled', '-6.899833,108.7115243', 'uploads/1756704469_IMG20250901104357_01.jpg', 'Branding poster jagung Reva dikios berkah Mulya tani Waled,Cirebon', 2, '2025-09-02 07:02:51', 'approved', '2025-09-01 12:27:50', '2025-09-02 07:02:51', 5, 2),
(112, 5, 7, NULL, '2025-09-01', 0.00, 'Waled cirebon', '-6.899833,108.7115243', 'uploads/1756704546_IMG20250901104406.jpg', 'Branding poster timun lavanta dikios berkah Mulya tani Waled,Cirebon', 2, '2025-09-01 19:52:45', 'approved', '2025-09-01 12:29:06', '2025-09-01 19:52:45', 5, 2),
(113, 6, 3, NULL, '2025-09-01', 750000.00, 'Ds. Argalingga Kec. Argapura Kab. Majalengka', '', 'uploads/1756711122_6610F1FE-F168-4670-99E5-0661C04DA6ED.jpeg', '', 2, '2025-09-01 19:53:36', 'approved', '2025-09-01 14:18:43', '2025-09-01 19:53:36', 6, 2),
(115, 8, 3, NULL, '2025-09-03', 750000.00, 'Ciater, Subang', '-6.7330017,107.6612993', 'uploads/1756881821_PhotoGrid_Plus_1756881629136.jpg', 'Field Trip (FT) Jagung Manis Madu-59 F1. \r\nPengenalan Produk Jagung Manis Madu-59 F1, Melihat hasil Panen, Uji Rasa dan Sharing teknis budidaya Jagung Manis Madu-59 F1 bersama Mitra Petani Kang Ujang.\r\nKecamatan Ciater, Subang.', 2, '2025-09-04 09:08:00', 'approved', '2025-09-03 13:43:41', '2025-09-04 09:08:00', 8, 2),
(116, 8, 7, NULL, '2025-09-03', 100000.00, 'Ciater, Subang', '-6.7345987,107.6620421', 'uploads/1756882075_PhotoGrid_Plus_1756882041445.jpg', 'Panen Jagung Manis Madu-59 F1', 2, '2025-09-04 09:07:53', 'approved', '2025-09-03 13:47:55', '2025-09-04 09:07:53', 8, 2),
(117, 7, 2, NULL, '2025-09-02', 250000.00, 'Randegan', '', 'uploads/1756890395_1000522816.jpg', 'Farmers Meeting (FM) bersama mitratani kios sobatani DS randegan, sharing all produk advanta (focus crop JM Madu 59,Lavanta, herra, beijing), \r\n🌽🥒🫘\r\nRandegan Jatitujuh', 2, '2025-09-04 09:07:42', 'approved', '2025-09-03 16:06:35', '2025-09-04 09:07:42', 7, 2),
(118, 5, 3, NULL, '2025-09-04', 630000.00, 'Pabedilan', '-6.6913417,108.4993834', 'uploads/1756991491_Picsart_25-09-04_10-23-16-278.jpg', 'Field trip bersama petani binaan kios suci Mulya tani dan kelompok tani pak senang dilahan pa Agus kawal dan melihat performa jagung Lilac serta mengenalkan jagung manis madu, Reva dan menginfokan jagung baru h72\r\nAlhamdulillah tanam kembali 6Lilac+ 4 madu', 2, '2025-09-04 23:59:20', 'approved', '2025-09-04 20:11:32', '2025-09-04 23:59:20', 5, 2),
(119, 5, 7, NULL, '2025-09-03', 0.00, 'Sindanglaut, cirebon', '-6.6913417,108.4993834', 'uploads/1756991697_IMG20250902112932.jpg', 'Branding poster gambar jagung madu dikios sumber tani', 2, '2025-10-08 21:31:01', 'approved', '2025-09-04 20:14:57', '2025-10-08 21:31:01', 5, 2),
(120, 8, 5, NULL, '2025-09-05', 0.00, 'Ciater, Subang', '-6.7375304,107.6704771', 'uploads/1757045124_20250905_110403.jpg', 'Kios Bumi Hijau Makmur', 2, '2025-09-05 18:43:17', 'approved', '2025-09-05 11:05:25', '2025-09-05 18:43:17', 8, 2),
(121, 8, 5, NULL, '2025-09-05', 0.00, 'Wanayasa, Purwakarta', '-6.6820603,107.5623117', 'uploads/1757061980_20250905_154230.jpg', 'Kios Fajar Tani Mandiri', 2, '2025-09-05 18:43:13', 'approved', '2025-09-05 15:46:21', '2025-09-05 18:43:13', 8, 2),
(122, 5, 3, NULL, '2025-09-07', 750000.00, 'Talun,Cirebon', '-6.6916609,108.4993834', 'uploads/1757419629_Picsart_25-09-07_11-49-54-850.jpg', 'Fieldtrip bersama ppl dan kelompok tani wilayah sumber, sarwadadi dan binaan pak Misbah sekaligus kelompok tani Adi jaya wilayah wanasaba menuju wilayah Kubang Talun Cirebon. Krop fokus tanaman jagung madu sekaligus panen jagung madu dan sold 1 dus jg mad', 2, '2025-09-09 20:16:55', 'approved', '2025-09-09 19:07:09', '2025-09-09 20:16:55', 5, 2),
(123, 7, 5, NULL, '2025-09-09', 0.00, 'Kios sinartani', '', 'uploads/1757425051_1000529666.jpg', '', 2, '2025-09-09 21:15:27', 'approved', '2025-09-09 20:37:32', '2025-09-09 21:15:27', 7, 2),
(124, 6, 1, 2, '2025-09-10', 200000.00, 'Mandiri Jaya Tani', '', 'uploads/1757552115_IMG_2533.jpeg', '', 9, '2025-09-11 10:35:22', 'approved', '2025-09-11 07:55:16', '2025-09-11 10:35:22', 6, 9),
(125, 19, 2, 6, '2025-09-08', 300000.00, 'Barujumaah, Cipada-Cisarua Kb. Bandung Barat', '', 'uploads/1757562036_1000391444.jpg', 'Ada pergeseran potensi produk yg awalnya daerah tersebut sentra buncis sekarang beralih ke timun, sehingga lavanta disambut positif.', NULL, NULL, 'not_responded', '2025-09-11 10:40:36', NULL, 19, NULL),
(126, 7, 3, 10, '2025-09-11', 700000.00, 'Karyamukti', '', 'uploads/1757586057_1000534057.jpg', '', 2, '2025-09-12 08:43:33', 'approved', '2025-09-11 17:20:57', '2025-09-12 08:43:33', 7, 2),
(127, 7, 3, 6, '2025-09-15', 750000.00, 'BanggalaKertajati', '', 'uploads/1757931337_1000533918.jpg', 'Field Trip (FT) / Stady banding. \r\nMelihat perfom timun lavanta dan Sharing teknis budidaya bersama Mitra Petani kios sobatani & tigaputritani\r\nPetani binaan lili gondrong, pak Suradi, pak aep, Noto, awi Cikamurang\r\nDi lahan milik pak darma umur 38hst\r\n🥒🥒🥒', 2, '2025-09-15 20:47:00', 'approved', '2025-09-15 17:15:38', '2025-09-15 20:47:00', 7, 2),
(128, 7, 5, 2, '2025-09-15', 50000.00, 'Kios cahayatani', '', 'uploads/1757931399_1000538576.jpg', 'Buah segarMadu,Beijing,lavanta', 2, '2025-09-15 20:46:32', 'approved', '2025-09-15 17:16:39', '2025-09-15 20:46:32', 7, 2),
(129, 7, 5, 10, '2025-09-15', 0.00, 'Kios agrotani', '', 'uploads/1757931579_1000539014.jpg', '', 2, '2025-09-15 20:46:20', 'approved', '2025-09-15 17:19:39', '2025-09-15 20:46:20', 7, 2),
(130, 7, 5, 6, '2025-09-15', 0.00, 'Kios sobatani', '', 'uploads/1757931628_1000539013.jpg', 'Display buah segar lavanta, Beijing', 2, '2025-09-15 20:46:12', 'approved', '2025-09-15 17:20:28', '2025-09-15 20:46:12', 7, 2),
(131, 5, 1, 4, '2025-09-15', 200000.00, 'Talun Cirebon', '-6.6925937,108.4972833', 'uploads/1757935751_Picsart_25-09-15_09-33-22-490.jpg', 'One day promotion dikios Adi jaya promosi benih jagung madu, Reva dan Lilac dikios Adi jaya Cirebon. Alhamdulillah sold 5 pcs', 2, '2025-09-15 20:46:51', 'approved', '2025-09-15 18:29:11', '2025-09-15 20:46:51', 5, 2),
(132, 5, 7, NULL, '2025-09-15', 0.00, 'Kios Adi jaya cirebon', '-6.6925937,108.4972833', 'uploads/1757935855_IMG20250915091715.jpg', 'Branding Baner jagung manis madu dikios Adi jaya', 2, '2025-10-01 09:46:00', 'approved', '2025-09-15 18:30:56', '2025-10-01 09:46:00', 5, 2),
(133, 6, 2, 2, '2025-09-15', 300000.00, 'Ds. Jalaksana Kec. Jalaksana Kab. Kuningan', '', 'uploads/1757952689_FAE6E8D6-C5B6-4B8C-861D-9B4845351DAC.jpeg', '', 2, '2025-09-16 20:54:59', 'approved', '2025-09-15 23:11:29', '2025-09-16 20:54:59', 6, 2),
(134, 6, 7, NULL, '2025-09-16', 0.00, 'Drajat Tani', '', 'uploads/1758027512_6448236f-f012-4662-8ed8-1507998f27d3.jpeg', '', 2, '2025-09-16 20:54:24', 'approved', '2025-09-16 19:58:32', '2025-09-16 20:54:24', 6, 2),
(135, 6, 7, NULL, '2025-09-17', 0.00, 'Kios Sukatani Sae', '', 'uploads/1758075785_73db10e7-f531-42ca-82c5-ecaec68291d0.jpeg', '', 2, '2025-09-17 19:26:28', 'approved', '2025-09-17 09:23:05', '2025-09-17 19:26:28', 6, 2),
(136, 7, 5, 10, '2025-09-17', 0.00, 'Kios sultan farm', '', 'uploads/1758084605_1000536083.jpg', '', 2, '2025-09-17 19:26:24', 'approved', '2025-09-17 11:50:06', '2025-09-17 19:26:24', 7, 2),
(137, 5, 5, 2, '2025-09-16', 0.00, 'Kios sumber tani Sindanglaut, cirebon', '-6.6926814,108.4978504', 'uploads/1758201232_IMG20250916115001.jpg', 'Display panenan jagung madu sekaligus tes rebusan ketengkulak rebusan jagung dipasar Sindanglaut', 2, '2025-09-19 13:22:03', 'approved', '2025-09-18 20:13:53', '2025-09-19 13:22:03', 5, 2),
(138, 7, 1, 6, '2025-09-20', 200000.00, 'Kios sobat tani', '', 'uploads/1758349618_1000545594.jpg', '', 2, '2025-09-21 15:55:04', 'approved', '2025-09-20 13:26:59', '2025-09-21 15:55:04', 7, 2),
(139, 15, 2, 2, '2025-09-22', 300000.00, 'Bugel, Banjaran', '', 'uploads/1758521564_FunPic_20250922_110845188.jpg', 'FM sekaligus penyuluhan penggunaan perlakuan benih sebelum tanam madu 59 F1.', NULL, NULL, 'not_responded', '2025-09-22 13:12:45', NULL, 15, NULL),
(140, 8, 2, 2, '2025-09-20', 300000.00, 'Serangpanjang, Subang', '', 'uploads/1758527163_20250920_140707.jpg', 'Farmer Meeting (FM)\r\nPengenalan produk Advanta. Fokus Produk Jagung Madu-59, Cabai Rawit Shima, Tomat Nona 23 F1, Timun Lavanta, dan Paria Beijing. bersama Petani binaan Pak Encas.\r\nPO Paria Beijing 10pcs.\r\nKecamatan Serangpanjang, Subang.', 2, '2025-09-22 17:39:47', 'approved', '2025-09-22 14:46:04', '2025-09-22 17:39:47', 8, 2),
(141, 7, 2, 6, '2025-09-22', 300000.00, 'Kasokandel', '', 'uploads/1758546972_1000548582.jpg', '', 2, '2025-09-23 21:40:02', 'approved', '2025-09-22 20:16:13', '2025-09-23 21:40:02', 7, 2),
(142, 19, 2, 2, '2025-09-15', 300000.00, 'Cikalong Wetan-Bandung Barat', '', 'uploads/1758628790_1000398994.jpg', 'Petani-petani yang hadir terlihat antusias disertai diskusi intens terhadap masalah pertanian. Output yg dihasilkan berupa repeat order terhadap beberapa produk advanta khususnya Madu, Lavanta, dan Nona', NULL, NULL, 'not_responded', '2025-09-23 18:59:50', NULL, 19, NULL),
(143, 19, 5, 6, '2025-09-11', 50000.00, 'Parongpong,Cikande,Ngamprah', '', 'uploads/1758630934_1000395445.jpg', '\"Bentuk buah dan warna timun lavanta secara umum dapat diterima oleh petani dan pasar\", testimoni tersebut terucap oleh beberapa petani dan kios yang disimpani display panenannya.', NULL, NULL, 'not_responded', '2025-09-23 19:35:34', NULL, 19, NULL),
(144, 19, 5, 2, '2025-09-12', 50000.00, 'Cisarua, Cukalong Wetan', '', 'uploads/1758631207_1000396147.jpg', 'Display yg disajikan berupa panenan tongkol jagung dan rebusan. Hal tersebut utk lebih meyakinkan kios yang belum pernah menjual produk madu-59 bahwa manisnya jagung ini lebih dari yang lain.', NULL, NULL, 'not_responded', '2025-09-23 19:40:08', NULL, 19, NULL),
(145, 5, 2, 4, '2025-09-24', 250000.00, 'Jatirenggang, pabuaran', '-6.8805086,108.7293281', 'uploads/1758695887_Picsart_25-09-24_12-40-01-764.jpg', 'Farmer meteeng bersama binaan kios berkah Mulya tani dan ppl dilahan pak Nana sekaligus tanam benih Reva 2 bungkus dan madu 5 bungkus dan order benih Reva kembali diwilayah jatirenggang Cirebon', 2, '2025-09-25 08:17:20', 'approved', '2025-09-24 13:38:08', '2025-09-25 08:17:20', 5, 2),
(146, 15, 2, 2, '2025-09-24', 300000.00, 'maruyung ,Pacet, Ciparay', '', 'uploads/1758708283_FunPic_20250924_094217210.jpg', 'FM kelompok tani binaan pak Deden pengenalan  madu 59 F1 dan timun lalab lavanta F1 deden', NULL, NULL, 'not_responded', '2025-09-24 17:04:44', NULL, 15, NULL),
(147, 6, 7, NULL, '2025-09-24', 0.00, 'Ds. Babakanmulya Kec. Jalaksana Kab. Kuningan', '', 'uploads/1758712228_IMG_3082.jpeg', '', 2, '2025-09-25 08:17:11', 'approved', '2025-09-24 18:10:29', '2025-09-25 08:17:11', 6, 2),
(148, 18, 1, 6, '2025-09-03', 300000.00, 'Kios Serbaguna Tani Rancakalong', '-7.3369849,108.2113306', 'uploads/1758798566_1000382478.webp', 'ODP Lavanta dan Madu', NULL, NULL, 'not_responded', '2025-09-25 18:09:26', '2025-09-25 18:11:19', 18, 18),
(149, 18, 1, 8, '2025-09-11', 300000.00, 'Kios G Manglayang Tani Ciseureuh Sumedang', '-7.3371228,108.2113678', 'uploads/1758798643_1000398816.webp', 'ODP Nona dan Shima', NULL, NULL, 'not_responded', '2025-09-25 18:10:43', '2025-09-25 18:11:07', 18, 18),
(150, 18, 4, 8, '2025-09-22', 1116000.00, 'Lahan Tomat Nona Pak Ajat Cijambu Sumedang', '-7.337121,108.2113659', 'uploads/1758798873_1000415688.webp', 'Diskusi di halaman rumah dan melihat perform tomat nona di kebun, alhamdulillah respon petani baik dan terjadi penjualan langsung pada saat acara berlangsung', NULL, NULL, 'not_responded', '2025-09-25 18:14:33', NULL, 18, NULL),
(151, 8, 3, 11, '2025-09-27', 750000.00, 'Ciater, Subang', '-6.7152383,107.6985183', 'uploads/1758961299_PhotoGrid_Plus_1758960768355.jpg', 'Study Banding / Field Trip (FT)\r\nMelihat Hasil Panen Cabai Rawit Shima dan pengenalan all produk Advanta. Fokus Produk Timun Lavanta, Jagung Madu-59, Tomat Nona 23 F1 dan Cabai Rawit Shima bersama Mitra Petani Pak Iwan.\r\nKecamatan Ciater, Subang', 2, '2025-09-28 18:46:49', 'approved', '2025-09-27 15:21:39', '2025-09-28 18:46:49', 8, 2),
(152, 8, 1, 2, '2025-09-29', 200000.00, 'Tanjungsiang, Subang', '-6.7532747,107.8162373', 'uploads/1759126665_PhotoGrid_Plus_1759127108357.jpg', 'ODP Kios Barokah Tani (Bu Hj Aneng)\r\nPengenalan produk Advanta ke petani di kios.\r\nTanjungsiang, Subang.', 2, '2025-09-29 13:56:53', 'approved', '2025-09-29 13:17:45', '2025-09-29 13:56:53', 8, 2),
(153, 17, 1, 2, '2025-09-24', 300000.00, 'Kios Rizky Amanah Tani', '', 'uploads/1759128267_1000817134.jpg', '', NULL, NULL, 'not_responded', '2025-09-29 13:44:28', NULL, 17, NULL),
(154, 17, 1, 6, '2025-09-25', 300000.00, 'Kios Tumbuh Agro Subur', '', 'uploads/1759128329_1000818310.jpg', '', NULL, NULL, 'not_responded', '2025-09-29 13:45:31', NULL, 17, NULL),
(155, 6, 2, 2, '2025-09-29', 300000.00, 'Ds. Sembawa Kec. Jalaksana Kab. Kuningan', '', 'uploads/1759129980_IMG-20250929-WA0024.jpg', '', 2, '2025-09-29 19:02:28', 'approved', '2025-09-29 14:13:00', '2025-09-29 19:02:28', 6, 2),
(156, 8, 1, 2, '2025-09-29', 200000.00, 'Tanjungsiang, Subang', '-6.7305233,107.8008983', 'uploads/1759130042_PhotoGrid_Plus_1759130492218.jpg', 'ODP Kios Tani Raharja (Pak Iwan)\r\nPengenalan produk Advanta ke petani di kios.\r\nTanjungsiang, Subang.', 2, '2025-09-29 19:02:20', 'approved', '2025-09-29 14:14:02', '2025-09-29 19:02:20', 8, 2),
(157, 6, 2, 2, '2025-09-29', 250000.00, 'Ds. Gandasoli Kec. Kramatmulya Kab. Kuningan', '', 'uploads/1759145318_IMG-20250929-WA0037.jpg', '', 2, '2025-09-29 19:02:07', 'approved', '2025-09-29 18:28:38', '2025-09-29 19:02:07', 6, 2),
(158, 15, 4, 2, '2025-09-29', 3700000.00, 'Cipinang, Cimaung', '-6.99412,107.5912325', 'uploads/1759152527_FunPic_20250927_145250085.jpg', 'Alhamdulillah kegitan Farmer Field Day (FFD),Semarak menyambut Musim Tanam Jagung Manis Madu-59 F1, Sharing teknis budidaya antar petani kunci wilayah Cimaung dan Arjasari, sekaligus melihat  panenan madu 59 F1', NULL, NULL, 'not_responded', '2025-09-29 20:28:47', NULL, 15, NULL),
(159, 15, 1, 2, '2025-09-26', 300000.00, 'Pinggir sari,arjasari', '', 'uploads/1759152667_FunPic_20250926_112405505.jpg', 'One day promtion di toko pertanian Putra Rahayu, Alhamdulillah deal 15 box madu 59 F1', NULL, NULL, 'not_responded', '2025-09-29 20:31:08', '2025-09-29 20:33:06', 15, 15),
(161, 16, 2, 11, '2025-09-29', 300000.00, 'Cisurupan cimayiy', '', 'uploads/1759156198_IMG_0331.jpeg', 'banyak saran petani pengen melihat langsung vigor tanaman sima, makanya demplot d dua lokasi di pak jhon dan pak h agus', NULL, NULL, 'not_responded', '2025-09-29 21:29:59', NULL, 16, NULL),
(162, 16, 2, 13, '2025-09-29', 150000.00, 'Pasirkiamis', '', 'uploads/1759156304_c0234b1a-ec77-45aa-b630-653a3071c201.jpeg', 'Sosialisasi cabai sima dan demplot tanam keriting agni 100 pupulasi', NULL, NULL, 'not_responded', '2025-09-29 21:31:45', NULL, 16, NULL),
(163, 5, 2, 2, '2025-09-29', 250000.00, 'Gunungjati', '-6.6925747,108.4970366', 'uploads/1759160981_Picsart_25-09-29_17-53-00-251.jpg', 'Farmer meteeng bersama petani kunci pak tarsudi bersama binannya diwilayah baru, mengenalkan benih jagung madu dan Lilac serta ajak tanam diwilayah gunung jati dan sekitarnya, Cirebon', 2, '2025-10-01 09:45:54', 'approved', '2025-09-29 22:49:41', '2025-10-01 09:45:54', 5, 2),
(164, 8, 7, NULL, '2025-09-30', 0.00, 'Ciater, Subang', '-6.7375239,107.6704836', 'uploads/1759199002_PhotoGrid_Plus_1759198942244.jpg', 'Kios Bumi Hijau Makmur', 2, '2025-10-01 09:45:47', 'approved', '2025-09-30 09:23:23', '2025-10-01 09:45:47', 8, 2),
(165, 8, 7, NULL, '2025-09-30', 0.00, 'Wanayasa, Purwakarta', '-6.6820625,107.5623193', 'uploads/1759207975_PhotoGrid_Plus_1759207853126.jpg', 'Kios Fajar Tani Mandiri', 2, '2025-10-01 09:45:41', 'approved', '2025-09-30 11:52:56', '2025-10-01 09:45:41', 8, 2),
(166, 7, 2, 6, '2025-09-30', 300000.00, 'Jatimulya', '', 'uploads/1759210405_1000555587.jpg', 'Farmers Meeting ( FM ) pengenalan produk advanta bersama petani DS. Jatimulya kasokandel\r\nProdak pokus lavanta,Beijing, kp.herra\r\nSold out 1iner lavanta, 1iner Beijing\r\n🌽🫘🥒🌶️\r\nKasokandel', 2, '2025-10-01 09:45:36', 'approved', '2025-09-30 12:33:26', '2025-10-01 09:45:36', 7, 2),
(167, 8, 2, 2, '2025-09-30', 300000.00, 'Serangpanjang, Subang', '', 'uploads/1759219449_PhotoGrid_Plus_1759219125476.jpg', 'Farmer Meeting (FM) Pengenalan produk Advanta. Fokus Produk Jagung Madu-59, Cabai Rawit Shima, Tomat Nona 23 F1, Timun Lavanta, dan Paria Beijing. bersama Petani binaan Pak Amad.\r\nKecamatan Serangpanjang, Subang.', 2, '2025-10-01 09:45:27', 'approved', '2025-09-30 15:04:10', '2025-10-01 09:45:27', 8, 2),
(168, 5, 8, NULL, '2025-09-30', 0.00, '', '-6.6904845,108.4967865', 'uploads/1759238158_IMG20250930201451.jpg', 'Berkas kegiatan bulan September 2025', 2, '2025-10-01 09:45:11', 'approved', '2025-09-30 20:15:59', '2025-10-01 09:45:11', 5, 2),
(169, 6, 8, NULL, '2025-09-30', 0.00, '', '', NULL, '', 2, '2025-10-01 09:55:22', 'approved', '2025-10-01 09:53:24', '2025-10-01 09:55:22', 9, 2),
(171, 8, 8, NULL, '2025-09-30', 0.00, '', '', NULL, '', 2, '2025-10-01 09:55:19', 'approved', '2025-10-01 09:53:55', '2025-10-01 09:55:19', 9, 2),
(172, 7, 8, NULL, '2025-09-30', 0.00, '', '-6.7320229,108.5523164', NULL, '', 2, '2025-10-01 15:31:41', 'approved', '2025-10-01 09:54:16', '2025-10-01 15:31:41', 9, 2),
(173, 18, 1, 2, '2025-10-01', 300000.00, 'Cikubang Pamulihan Sumedang', '-6.8634439,107.8203007', 'uploads/1759297552_1000443732.webp', 'Fokus Produk Madu dan Lavanta,Display Hasil Panen Tomat Nona dan Pengenalan Semua Produk Advanta', NULL, NULL, 'not_responded', '2025-10-01 12:45:52', NULL, 18, NULL),
(174, 6, 5, 8, '2025-10-01', 0.00, 'Cahaya Abadi Utama Tani', '', 'uploads/1759309190_IMG-20251001-WA0056.jpg', '', 2, '2025-10-02 05:31:38', 'approved', '2025-10-01 15:59:50', '2025-10-02 05:31:38', 6, 2),
(175, 6, 5, 8, '2025-10-01', 0.00, 'Ade Parno Tani', '', 'uploads/1759309264_IMG-20251001-WA0057.jpg', '', 2, '2025-10-02 05:31:36', 'approved', '2025-10-01 16:01:04', '2025-10-02 05:31:36', 6, 2);
INSERT INTO `activities` (`id`, `user_id`, `type_id`, `product_id`, `date`, `cost`, `location`, `latlong`, `image_path`, `notes`, `responded_by_id`, `responded_datetime`, `status`, `created_datetime`, `updated_datetime`, `created_by_uid`, `updated_by_uid`) VALUES
(176, 6, 5, 8, '2025-10-01', 0.00, 'Kurnia Tani', '', 'uploads/1759309302_IMG-20251001-WA0058.jpg', '', 2, '2025-10-02 05:31:33', 'approved', '2025-10-01 16:01:42', '2025-10-02 05:31:33', 6, 2),
(177, 6, 5, 8, '2025-10-01', 0.00, 'Dentis Jaya Tani', '', 'uploads/1759309338_IMG-20251001-WA0059.jpg', '', 2, '2025-10-02 05:31:30', 'approved', '2025-10-01 16:02:18', '2025-10-02 05:31:30', 6, 2),
(178, 6, 5, 8, '2025-10-01', 0.00, 'Kiya Tani', '', 'uploads/1759309388_IMG-20251001-WA0060.jpg', '', 2, '2025-10-02 05:31:27', 'approved', '2025-10-01 16:03:08', '2025-10-02 05:31:27', 6, 2),
(179, 8, 7, NULL, '2025-10-01', 0.00, 'Tanjungsiang, Subang', '', 'uploads/1759313513_20251001_095534.jpg', 'Kios Barokah Tani', 2, '2025-10-02 05:31:24', 'approved', '2025-10-01 17:11:53', '2025-10-02 05:31:24', 8, 2),
(180, 8, 7, NULL, '2025-10-01', 0.00, 'Tanjungsiang, Subang', '', 'uploads/1759313550_20251001_100804.jpg', 'Kios Tani Raharja', 2, '2025-10-02 05:31:21', 'approved', '2025-10-01 17:12:31', '2025-10-02 05:31:21', 8, 2),
(181, 8, 7, NULL, '2025-10-01', 0.00, 'Jalancagak, Subang', '', 'uploads/1759313592_20251001_115112.jpg', 'Kios KUD Rahayu', 2, '2025-10-02 05:31:18', 'approved', '2025-10-01 17:13:13', '2025-10-02 05:31:18', 8, 2),
(182, 8, 3, 6, '2025-10-03', 750000.00, 'Desa Nagrak Kec. Ciater Subang', '', 'uploads/1759484176_PhotoGrid_Plus_1759483905778.jpg', 'Study Banding / Field Trip (FT)\r\nMelihat Hasil Panen Timun Lavanta F1 dan pengenalan all produk Advanta. Fokus Produk Timun Lavanta, Jagung Madu-59, Tomat Nona 23 F1 dan Cabai Rawit Shima bersama Mitra Petani Kang Aji\r\nKecamatan Ciater, Subang.', 9, '2025-10-05 14:12:49', 'approved', '2025-10-03 16:36:16', '2025-10-05 14:12:49', 8, 9),
(183, 7, 2, 2, '2025-10-03', 300000.00, 'Cijati Majalengka', '', 'uploads/1759563964_1000563427.jpg', 'Farmers Meeting ( FM ) pengenalan produk advanta bersama petani Ds.Cijati \r\nProdak pokus Madu, lilac, \r\nSold out 7pcs Lilac, 2 pcs madu\r\n🌽🫘🥒🌶️\r\nCijati Majalengka', 9, '2025-10-05 14:12:39', 'approved', '2025-10-04 14:46:04', '2025-10-05 14:12:39', 7, 9),
(184, 7, 3, 1, '2025-10-06', 750000.00, 'Majasuka palasah', '', 'uploads/1759728155_1000563483.webp', '', 2, '2025-10-07 06:31:38', 'approved', '2025-10-06 12:22:35', '2025-10-07 06:31:38', 7, 2),
(185, 7, 3, 6, '2025-10-07', 750000.00, 'MekarmulyaKertajati', '', 'uploads/1759805366_1000565792.jpg', '', 2, '2025-10-08 21:30:50', 'approved', '2025-10-07 09:49:26', '2025-10-08 21:30:50', 7, 2),
(186, 8, 1, 2, '2025-10-07', 200000.00, 'Ds. Tanggulun Timur Kec. Kalijati Subang', '-6.5489476,107.6518892', 'uploads/1759812945_PhotoGrid_Plus_1759812747332.jpg', 'ODP Kios Berkah Tani (Pak Tiswo)\r\nPenyerapan produk Jagung Manis Madu-59 F1 di kios untuk rencana penanaman menjelang tahun baru.\r\nKalijati, Subang.', 2, '2025-10-08 21:30:41', 'approved', '2025-10-07 11:55:45', '2025-10-08 21:30:41', 8, 2),
(187, 8, 7, NULL, '2025-10-07', 0.00, 'Kalijati, Subang', '-6.5489465,107.651886', 'uploads/1759812995_20251007_114336.jpg', 'Kios Berkah Tani Tanggulun', 2, '2025-10-08 21:20:36', 'approved', '2025-10-07 11:56:35', '2025-10-08 21:20:36', 8, 2),
(188, 18, 2, 8, '2025-10-03', 300000.00, 'Ciseureuh Sumedang', '-6.9416176,107.5923451', 'uploads/1759821282_1000450114.webp', '_Farmers Meeting_ Petani Binaan Kios G Manglayang Tani, Diskusi dan Pengenalan _All Produc_ Advanta, Sumedang.', NULL, NULL, 'not_responded', '2025-10-07 14:14:42', NULL, 18, NULL),
(189, 5, 3, 2, '2025-10-06', 700000.00, 'Sawahgede sumber', '-6.8807777,108.7294904', 'uploads/1759904409_IMG-20251006-WA0008.jpg', 'Ft maju karena panen dimajukan.\r\nFieldtrip bersama binaan pak warma sumber dan binaan pak Adi talun menuju wilayah sawah gede disarwadadi Cirebon. Melihat performa jagung madu dan sold 9 bungkus madu dan order kembali 1 dus untuk penanaman tahun baru', 2, '2025-10-08 21:20:30', 'approved', '2025-10-08 13:20:09', '2025-10-08 21:20:30', 5, 2),
(190, 5, 3, 1, '2025-10-03', 700000.00, 'Weru, cirebon', '-6.8806637,108.7295009', 'uploads/1759904777_IMG-20251003-WA0011.jpg', 'Fieldtrip bersama bandar sirad dan bandar Heri wilayah batembat bersama ppl dan binaan mas Hadi wilayah Megu untuk melihat tanaman Lilac serta panen dan sekaligus mengenalkan benih madu, Reva dan lainnya. Tanam 15 madu dan Lilac 9 lagi', 2, '2025-10-08 21:20:26', 'approved', '2025-10-08 13:26:18', '2025-10-08 21:20:26', 5, 2),
(191, 5, 5, 2, '2025-10-08', 0.00, 'MatanghajiCirebon', '-6.8806562,108.7294665', 'uploads/1759904951_IMG20251006144926.jpg', 'Display jagung madu dikios umi tani cirebon', 2, '2025-10-08 21:20:17', 'approved', '2025-10-08 13:29:11', '2025-10-08 21:20:17', 5, 2),
(192, 5, 5, 4, '2025-10-03', 0.00, 'Ciledug', '-6.8806562,108.7294665', 'uploads/1759905170_IMG20251001144414.jpg', 'Display panenan jagung Reva dan Lilac dikios suci Mulyatani ciledug', 2, '2025-10-08 21:20:15', 'approved', '2025-10-08 13:32:50', '2025-10-08 21:20:15', 5, 2),
(193, 5, 5, 4, '2025-10-03', 0.00, 'Waled', '-6.8806562,108.7294665', 'uploads/1759905254_IMG20251001150500.jpg', 'Display panenan jagung Reva dan Lilac dikios mas tatang', 2, '2025-10-08 21:20:11', 'approved', '2025-10-08 13:34:14', '2025-10-08 21:20:11', 5, 2),
(194, 5, 5, 2, '2025-10-07', 0.00, 'Sndanglaut', '-6.8806562,108.7294665', 'uploads/1759905435_IMG20250916122642.jpg', 'Display panenan jagung manis madu dikios tani makmur', 2, '2025-10-08 21:20:09', 'approved', '2025-10-08 13:37:15', '2025-10-08 21:20:09', 5, 2),
(195, 5, 7, NULL, '2025-10-01', 0.00, 'Waled', '-6.8806445,108.7294501', 'uploads/1759905523_IMG20251001121200.jpg', 'Branding poster jagung Reva disepanjang jalan waled', 2, '2025-10-08 21:20:06', 'approved', '2025-10-08 13:38:44', '2025-10-08 21:20:06', 5, 2),
(196, 5, 7, NULL, '2025-10-01', 0.00, 'Talun', '-6.8805757,108.7293787', 'uploads/1759905600_IMG20250926154829.jpg', 'Branding panenan putren untuk dikirim ke pasar jagasatru cirebon', 2, '2025-10-08 21:20:03', 'approved', '2025-10-08 13:40:00', '2025-10-08 21:20:03', 5, 2),
(197, 18, 3, 6, '2025-10-04', 864000.00, 'Cibungur Sumedang', '-6.9163642,107.7099278', 'uploads/1759928394_1000420191.webp', '1. Timun Lavanta Memiliki Ketahanan Virus dan Layu Yang Cukup Baik\r\n2. Buah Pangkal Pada Batang Utama Tidak Terlalu Banyak\r\n3. Memiliki Banyak Seler dan Setiap Seler/Percabangan Tumbuh Kembali Buah\r\n4. Warna dan Ukuran Buah Mirip Kompetitor Biasa Ditanam', NULL, NULL, 'not_responded', '2025-10-08 19:59:55', '2025-10-08 22:11:46', 18, 18),
(198, 6, 1, 2, '2025-10-03', 300000.00, 'Sri Mulya Tani', '', 'uploads/1759970141_IMG-20251009-WA0001.jpg', '', 2, '2025-10-09 21:06:57', 'approved', '2025-10-09 07:35:41', '2025-10-09 21:06:57', 6, 2),
(199, 6, 3, 8, '2025-10-08', 750000.00, 'Ds. Sidaraja Kec. Cingambul Kab. Majalengka', '', 'uploads/1759970208_IMG_20251008_154444_841.webp', '', 2, '2025-10-09 21:07:23', 'approved', '2025-10-09 07:36:48', '2025-10-09 21:07:23', 6, 2),
(200, 7, 5, 6, '2025-10-08', 0.00, 'Kios sinartani', '', 'uploads/1759986589_1000569918.jpg', '', 2, '2025-10-09 21:06:50', 'approved', '2025-10-09 12:09:49', '2025-10-09 21:06:50', 7, 2),
(201, 6, 2, 2, '2025-10-10', 300000.00, 'Ds. Sukamukti Kec. Jalaksana Kab. Kuningan', '', 'uploads/1760083415_IMG-20251010-WA0033.jpg', '', 2, '2025-10-10 18:44:52', 'approved', '2025-10-10 15:03:35', '2025-10-10 18:44:52', 6, 2),
(202, 18, 3, 8, '2025-10-10', 737000.00, 'Lahan Tomat Nona Pak Apip Malaka Sumedang', '-6.9163638,107.7099256', 'uploads/1760093460_1000466633.webp', '1. Tomat Nona Memiliki Kelebihan Dari Segi Ketahanan Virus dan Layu Dibandingkan Kompetitor\r\n2. Ukuran dan Warna Buah Disukai Petani dan Sudah Kirim ke Pasar Tidak Ada Kendala\r\n3. Kekerasan Buah Cukup Baik\r\n4. Untuk Bentuk Buah Cenderung Bulat', NULL, NULL, 'not_responded', '2025-10-10 17:51:01', NULL, 18, NULL),
(203, 18, 1, 11, '2025-10-09', 300000.00, 'Kios Subur Tani Pasar Tanjungsari Sumedang', '-6.9164143,107.7099118', 'uploads/1760093604_1000464031.webp', 'menginformasikan semua perihal produk Advanta terkhusus produk yang sudah tersedia di Kios Subur Tani. Beberapa pengunjung baik petani perorangan maupun bandar mulai tertarik dengan produk advanta. Alhamdulillah sold out 5pcs Tomat Nona Oleh A Cucun', NULL, NULL, 'not_responded', '2025-10-10 17:53:24', NULL, 18, NULL),
(204, 8, 3, 6, '2025-10-10', 750000.00, 'Ds. Ponggang Kec. Serangpanjang Subang', '', 'uploads/1760098445_PhotoGrid_Plus_1760098277961.jpg', 'Study Banding / Field Trip (FT)\r\nMelihat Hasil Panen Timun Lavanta F1 dan pengenalan all produk Advanta. Fokus Produk Timun Lavanta, Jagung Madu-59, Tomat Nona 23 F1 dan Cabai Rawit Shima bersama Mitra Petani Kang Wawan.\r\nKecamatan Serangpanjang, Subang.', 2, '2025-10-13 09:21:02', 'approved', '2025-10-10 19:14:05', '2025-10-13 09:21:02', 8, 2),
(205, 8, 7, NULL, '2025-10-13', 0.00, 'Plered, Purwakarta', '-6.6460416,107.3714918', 'uploads/1760341486_20251013_144048.jpg', 'Kios Rizky Tani', 2, '2025-10-13 17:35:37', 'approved', '2025-10-13 14:44:46', '2025-10-13 17:35:37', 8, 2),
(206, 5, 2, 2, '2025-10-10', 250000.00, 'Cempaka Arum cirebon', '-6.6927111,108.497835', 'uploads/1760363286_IMG-20251010-WA0015.jpg', 'Farmer meteeng bersama binaan pak Adi  sekaligus kirim benih madu 2 dus dan penanaman Lilac 10 bungkus diwilayah cempaka arum cirebon\r\nNot. kegiatan fm diwaled dialihkan karena petani binaan sedang ziarah kewali 9', 2, '2025-10-15 20:18:06', 'approved', '2025-10-13 20:48:06', '2025-10-15 20:18:06', 5, 2),
(207, 8, 1, 2, '2025-10-14', 200000.00, 'Ds. Tanjungsari Kec. Cikaum Subang', '', 'uploads/1760424791_PhotoGrid_Plus_1760424155942.jpg', 'Kios Parvis Tani', 2, '2025-10-15 20:18:01', 'approved', '2025-10-14 13:53:11', '2025-10-15 20:18:01', 8, 2),
(208, 8, 7, NULL, '2025-10-14', 0.00, 'Cikaum, Subang', '', 'uploads/1760424834_20251014_125325.jpg', 'Kios Parvis Tani', 2, '2025-10-15 20:17:50', 'approved', '2025-10-14 13:53:55', '2025-10-15 20:17:50', 8, 2),
(209, 7, 1, 6, '2025-10-15', 200000.00, 'ODP KIOS AGROTANI\r\n🌽🫘🥒\r\nKertajati', '', 'uploads/1760493037_1000572909.jpg', 'ODP KIOS AGROTANI\r\n🌽🫘🥒\r\nKertajati', 2, '2025-10-15 20:17:43', 'approved', '2025-10-15 08:50:38', '2025-10-15 20:17:43', 7, 2),
(210, 6, 2, 2, '2025-10-17', 300000.00, 'Ds. Sidamulya Kec. Jalaksana Kab. Kuningan', '', 'uploads/1760702018_6475F6D7-6665-4AE6-8992-69F718FB5D63.jpeg', '', 2, '2025-10-18 09:10:10', 'approved', '2025-10-17 18:53:38', '2025-10-18 09:10:10', 6, 2),
(211, 7, 2, 6, '2025-10-17', 300000.00, 'DS.cipaku kec.kadipaten', '', 'uploads/1760702956_1000576675.jpg', 'Farmers Meeting (FM) pengenalan produk advanta bersama petani Ds.cipaku kec.kadipaten', 2, '2025-10-18 09:09:52', 'approved', '2025-10-17 19:09:16', '2025-10-18 09:09:52', 7, 2),
(212, 8, 7, NULL, '2025-10-21', 0.00, 'Sagalaherang, Subang', '-6.7120758,107.6379943', 'uploads/1761020918_PhotoGrid_Plus_1761020846073.jpg', 'Tempat Persemaian Pak Dedi', 2, '2025-10-23 06:09:39', 'approved', '2025-10-21 11:28:38', '2025-10-23 06:09:39', 8, 2),
(213, 5, 1, 2, '2025-10-18', 200000.00, 'Kios umi tani matanghaji Cirebon', '-6.8217419,108.705113', 'uploads/1761105780_Picsart_25-10-18_08-35-45-812.jpg', 'One day promotion dikios umi tani crop produk focus benih jagung manis madu, timun lavanta, KCP Herra dimatanghaji cirebon', 2, '2025-10-23 06:09:29', 'approved', '2025-10-22 11:03:00', '2025-10-23 06:09:29', 5, 2),
(214, 5, 2, 4, '2025-10-15', 250000.00, 'Ciledug', '-6.8217312,108.7051221', 'uploads/1761105929_IMG-20251022-WA0013.jpg', 'Pengenalan jagung Reva kepetani binaan kios suci Mulyatani dan sekaligus mengenalkanjagungmadu, h72 danLilac dan ajak untuk penanaman diwilayah tersebut,Ciledug cirebon.k', 2, '2025-10-23 06:09:19', 'approved', '2025-10-22 11:05:29', '2025-10-23 06:09:19', 5, 2),
(215, 5, 7, NULL, '2025-10-17', 0.00, 'Waled', '-6.8177883,108.7116941', 'uploads/1761106063_IMG20251017102555.jpg', 'Menambahkan branding poster jagung madu dipinggir jalan hamparan penanaman jagung diwaled', 2, '2025-10-23 06:09:12', 'approved', '2025-10-22 11:07:43', '2025-10-23 06:09:12', 5, 2),
(216, 8, 7, NULL, '2025-10-22', 0.00, 'Bungursari, Purwakarta', '', 'uploads/1761116037_IMG-20251022-WA0008.jpg', 'Kelompok tani pak kunyang', 2, '2025-10-23 06:09:02', 'approved', '2025-10-22 13:53:57', '2025-10-23 06:09:02', 8, 2),
(217, 5, 2, 4, '2025-10-22', 250000.00, 'Pabuaran', '-6.6904989,108.4964155', 'uploads/1761130111_Picsart_25-10-22_11-27-38-261.jpg', 'Farmer meteeng bersama binaan kios suci Mulya tani diwilayah pabuaran, menginfokan dan mengenalkan sekaligus mengajak tanam benih advanta khususnya jagung madu, Reva dan mengenalkan jagung h72 untuk penanaman selanjutnya dan mengajak tanam Lilacdan sayura', 2, '2025-10-23 06:08:45', 'approved', '2025-10-22 17:48:31', '2025-10-23 06:08:45', 5, 2),
(218, 15, 1, 6, '2025-10-03', 300000.00, 'Toko pertanian Rizky mandiri,Jagabaya,cimaung', '-6.9942297,107.5912713', 'uploads/1761133700_FunPic_20251003_094736353.jpg', 'Fokus prodak madu 59 F1 dan timun Lavanta F1', NULL, NULL, 'not_responded', '2025-10-22 18:48:20', '2025-10-22 18:48:44', 15, 15),
(219, 8, 7, NULL, '2025-10-23', 0.00, 'Plered, Purwakarta', '-6.6461458,107.3715664', 'uploads/1761194487_20251023_114012.jpg', 'Kios Rizky Tani', NULL, NULL, 'not_responded', '2025-10-23 11:41:27', '2025-11-24 17:27:25', 8, 2),
(220, 6, 2, 2, '2025-10-23', 300000.00, 'Ds. Babakanmulya Kec. Jalaksana Kab. Kuningan', '', 'uploads/1761216321_IMG-20251023-WA0038.jpg', '', 2, '2025-10-23 18:48:02', 'approved', '2025-10-23 17:45:21', '2025-10-23 18:48:02', 6, 2),
(221, 16, 4, 2, '2025-10-15', 3506000.00, 'Samarang. Kebun pak amang', '', 'uploads/1761264827_IMG_1249.jpeg', 'Acara ffd respon petani untuk tanam si madu baik, terkendala harga jual d pasar masih di bawah kompotitor paragon. Sehingga petani sering di manfaatkan oleh para bandar beli lebih bawah d bandingkan dengandi pasar', NULL, NULL, 'not_responded', '2025-10-24 07:13:47', NULL, 16, NULL),
(222, 16, 3, 6, '2025-10-09', 740000.00, 'Samarang kebun pak dadan', '', 'uploads/1761265147_5c906122-2c11-484e-b5c1-f20d9b6124f6.jpeg', 'Respon lavanata baik,ukuran buah bagus dan warna di sukai lapak cikopo,keramat jati, cibitung', NULL, NULL, 'not_responded', '2025-10-24 07:19:07', NULL, 16, NULL),
(223, 16, 2, 2, '2025-10-23', 300000.00, 'Samarang', '', 'uploads/1761265251_IMG_0554.jpeg', 'Kenalkan prodak madu, lavanta dan shima', NULL, NULL, 'not_responded', '2025-10-24 07:20:52', NULL, 16, NULL),
(224, 8, 1, 2, '2025-10-24', 200000.00, 'Kalijati, Subang', '', 'uploads/1761273355_PhotoGrid_Plus_1761273325012.jpg', 'Kios Tani Meysha', 2, '2025-10-24 11:53:32', 'approved', '2025-10-24 09:35:56', '2025-10-24 11:53:32', 8, 2),
(225, 8, 7, NULL, '2025-10-24', 0.00, 'Bungursari, Purwakarta', '', 'uploads/1761274848_IMG-20251024-WA0003.jpg', 'Kebun KCP Herra 22 Pak Kunyang', 2, '2025-10-24 11:53:20', 'approved', '2025-10-24 10:00:48', '2025-10-24 11:53:20', 8, 2),
(226, 6, 3, 8, '2025-10-24', 750000.00, 'Ds. Sukadana Kec. Argapura Kab. Majalengka', '-6.903900336441545,108.33154197402172', 'uploads/1761293574_701CB0CF-A7C9-44B5-B846-EF904AB3EB26.jpeg', '', 2, '2025-10-24 15:19:02', 'approved', '2025-10-24 15:12:54', '2025-10-24 15:19:02', 6, 2),
(227, 19, 2, 2, '2025-10-06', 300000.00, 'Pagerwangi-Lembang', '', 'uploads/1761293770_1000420436.jpg', 'Daerah rintisan baru yang perlu effort lebih untuk mempromosikan produk advanta. Perlahan diperkenalkan dengan segala kelebihan yang dimiliki.', NULL, NULL, 'not_responded', '2025-10-24 15:16:10', NULL, 19, NULL),
(228, 19, 3, 6, '2025-10-21', 800000.00, 'Margaasih-Bandung', '', 'uploads/1761294080_1000435923.jpg', 'Kegiatan ini dalam rangka utk lebih meyakinkan lagi petani dan kios yang sebelumnya sudah order lavanta. Melihat performance lavanta secara langsung tentu akan menambah kepercayaan diri petani dan kios tersebut untuk mengenalkan kepada petani binaannya.', NULL, NULL, 'not_responded', '2025-10-24 15:21:20', NULL, 19, NULL),
(229, 19, 5, 2, '2025-10-22', 70000.00, 'Kios Tani Mas dan Sinar Mulya', '', 'uploads/1761294525_1000439985.jpg', 'Display produk terdiri dari lavanta dan madu serta sampling rebusan jagung matang. Diharapkan produk yang tersedia lebih variatif. Sejauh ini strategi ini cukup berhasil.', NULL, NULL, 'not_responded', '2025-10-24 15:28:45', NULL, 19, NULL),
(230, 7, 2, 6, '2025-10-24', 250000.00, 'Jatimulya kasokandel', '', 'uploads/1761324978_1000589497.jpg', 'Farmers Meeting (FM) pengenalan produk advanta bersama petani Ds.jatimulya Kec.kasokandel\r\n🌽🥒🫘', 2, '2025-10-25 18:25:30', 'approved', '2025-10-24 23:56:18', '2025-10-25 18:25:30', 7, 2),
(231, 7, 5, 6, '2025-10-24', 0.00, 'Kios agrotani', '', 'uploads/1761325060_1000589386.jpg', '', 2, '2025-10-25 18:25:27', 'approved', '2025-10-24 23:57:41', '2025-10-25 18:25:27', 7, 2),
(232, 15, 3, 2, '2025-10-25', 800000.00, 'Gading Tutuka,Ciluncat, Kec. Cangkuang, Kabupaten Bandung.', '', 'uploads/1761361754_FunPic_20251024_150100224.jpg', 'Fild trip petani binaan pak Abdul dari Sukanagara kelahan jagung manis Madu 59 F1 milik pak Dani,shering perawatan pemeliharaan madu 59 F1 dan sekaligus melihat hasil panenannya.', NULL, NULL, 'not_responded', '2025-10-25 10:09:14', '2025-10-25 10:09:34', 15, 15),
(233, 19, 2, 6, '2025-10-25', 300000.00, 'Cipatat-Bandung Barat', '', 'uploads/1761387142_1000441039.jpg', 'Lavanta menjadi fokus bahasan, terdapat kritik dan saran terkait produk. Namun antusiasme keinginan utk mencoba terlihat dari diskusi yang berlangsung hangat dan intens.', NULL, NULL, 'not_responded', '2025-10-25 17:12:22', NULL, 19, NULL),
(234, 5, 8, NULL, '2025-10-26', 0.00, 'Cirebon', '-6.6929365,108.4976695', 'uploads/1761457923_IMG20251026124755.jpg', '', 2, '2025-10-26 16:06:58', 'approved', '2025-10-26 12:52:03', '2025-10-26 16:06:58', 5, 2),
(235, 7, 8, NULL, '2025-10-26', 0.00, 'Majalengka', '', 'uploads/1761461186_1000591671.jpg', '', 2, '2025-10-26 16:06:53', 'approved', '2025-10-26 13:46:26', '2025-10-26 16:06:53', 7, 2),
(236, 8, 8, NULL, '2025-10-26', 0.00, 'Subang, Jawabarat', '', 'uploads/1761464318_20251026_143707.jpg', '', 2, '2025-10-26 16:06:50', 'approved', '2025-10-26 14:38:39', '2025-10-26 16:06:50', 8, 2),
(237, 6, 8, NULL, '2025-10-27', 0.00, '', '', NULL, '', 2, '2025-10-27 06:13:41', 'approved', '2025-10-27 05:59:23', '2025-10-27 06:13:41', 6, 2),
(238, 17, 3, 6, '2025-10-01', 800000.00, 'Rancabango, Garut', '', 'uploads/1761523241_1000825951.png', '', NULL, NULL, 'not_responded', '2025-10-27 07:00:42', NULL, 17, NULL),
(239, 17, 2, 2, '2025-10-09', 300000.00, 'Curug, Banyuresmi, Garut.', '', 'uploads/1761523314_1000837703.png', '', NULL, NULL, 'not_responded', '2025-10-27 07:01:55', '2025-10-27 07:02:30', 17, 17),
(240, 17, 2, 6, '2025-10-10', 300000.00, 'Tarogong, Garut.', '', 'uploads/1761523432_1000838650.png', '', NULL, NULL, 'not_responded', '2025-10-27 07:03:53', NULL, 17, NULL),
(241, 17, 1, 2, '2025-10-13', 300000.00, 'Kios Mitra Usaha Tani', '', 'uploads/1761523481_1000843916.png', '', NULL, NULL, 'not_responded', '2025-10-27 07:04:42', NULL, 17, NULL),
(242, 17, 1, 2, '2025-10-24', 300000.00, 'Kios Tumbuh Agro Subur', '', 'uploads/1761523527_1000858993.png', '', NULL, NULL, 'not_responded', '2025-10-27 07:05:27', NULL, 17, NULL),
(243, 17, 4, 2, '2025-10-25', 4000000.00, 'Wanaraja, Garut.', '', 'uploads/1761523580_1000862402.png', '', NULL, NULL, 'not_responded', '2025-10-27 07:06:21', NULL, 17, NULL),
(244, 8, 7, NULL, '2025-10-29', 0.00, 'Serangpanjang, Subang', '', 'uploads/1761720360_20251029_112537.jpg', 'Tempat Persemaian Bapak Idin', NULL, NULL, 'not_responded', '2025-10-29 13:46:01', '2025-11-24 17:27:19', 8, 2),
(245, 6, 7, NULL, '2025-10-31', 0.00, 'Persemaian Malaraman Tani', '-6.957664526817355,108.45123710972624', 'uploads/1761870346_IMG_0813.jpeg', '', 2, '2025-10-31 08:20:12', 'approved', '2025-10-31 07:25:47', '2025-10-31 08:20:12', 6, 2),
(246, 7, 3, 6, '2025-11-03', 750000.00, 'Karang anayr', '', 'uploads/1762163489_1000596649.jpg', 'Field Trip (FT)\r\nMelihat Hasil Panen Timun Lavanta F1 dan pengenalan all produk Advanta. Fokus Produk Timun Lavanta, Beijing , kacang panjang herra  bersama Mitra Petani Kang Pipin dan petani gadel indramayu.\r\nDilahan pak Dede\r\nUmur 44 hst (petikan ke 6)\r\n🥒', 2, '2025-11-04 06:51:43', 'approved', '2025-11-03 16:51:30', '2025-11-04 06:51:43', 7, 2),
(247, 7, 5, 6, '2025-11-03', 0.00, 'Kios sobatani', '', 'uploads/1762163600_1000589387.jpg', '', 2, '2025-11-04 06:51:12', 'approved', '2025-11-03 16:53:21', '2025-11-04 06:51:12', 7, 2),
(248, 5, 2, 4, '2025-11-01', 250000.00, 'Megu', '-6.6901653,108.4967865', 'uploads/1762473841_IMG-20251028-WA0097(2).jpg', 'Farmer meteeng bersama binaan petani dan kelompok tani mas Hadi mengajak untuk tanam jagung reva, sekaligus kawal panenan jagung Lilac dan kawal penanaman jagung Reva 2 bungkus serta Lilac 6 bungkus diwilayah weru dan megu', 2, '2025-11-08 05:28:20', 'approved', '2025-11-07 07:04:01', '2025-11-08 05:28:20', 5, 2),
(249, 5, 2, 2, '2025-11-05', 250000.00, 'Pamijahan cirebon', '-6.6901653,108.4967865', 'uploads/1762474080_IMG-20251028-WA0099.jpg', 'Farmer meteeng bersama binaan pak Adi dan ppl pak Rojai sekaligus kawal penanaman jagung madu 1 dus dan Lilac 4 Bungkus dipamijahan plumbon dan dikaliwadas sumber', 2, '2025-11-08 05:28:36', 'approved', '2025-11-07 07:08:00', '2025-11-08 05:28:36', 5, 2),
(250, 5, 3, 1, '2025-11-03', 750000.00, 'Karangsari', '-6.6921844,108.5023513', 'uploads/1762474333_IMG-20251103-WA0014.jpg', 'Fieldtrip dilahan pak sihab dan pak parno didua tempat. Bersama bandar baru mas Dion dan bandar lapak pasar jagasatru serta ppl dan petani binaan pak sihab diwilayah Plumbon, pamijahan, weru menuju wilayah Karangsari melihat perform tanama Lilac dan hasil', 2, '2025-11-08 05:29:55', 'approved', '2025-11-07 07:12:14', '2025-11-08 05:29:55', 5, 2),
(251, 5, 7, NULL, '2025-11-07', 0.00, 'Weru', '-6.6904271,108.4982704', 'uploads/1762474545_IMG-20251106-WA0068.jpg', 'Branding dilapak jualan jagung mas hadi dan sekaligus mengenalkan panenan jagung madu', 2, '2025-11-16 15:59:06', 'rejected', '2025-11-07 07:15:45', '2025-11-16 15:59:06', 5, 2),
(252, 5, 7, NULL, '2025-11-06', 0.00, 'Karangsari', '-6.6921844,108.5023513', 'uploads/1762474710_IMG20251106130000.jpg', 'Branding poster Lilac untuk kiriman pasar Jawatengah di bandar mas arka', 2, '2025-11-08 05:29:32', 'approved', '2025-11-07 07:18:30', '2025-11-08 05:29:32', 5, 2),
(253, 5, 7, NULL, '2025-11-03', 0.00, 'Karangsari', '-6.6921844,108.5023513', 'uploads/1762474973_IMG20251102161149.jpg', 'Branding poster jagung Lilac untuk pengriman pasar jagasatru', 2, '2025-11-08 05:29:29', 'approved', '2025-11-07 07:22:54', '2025-11-08 05:29:29', 5, 2),
(254, 5, 7, NULL, '2025-11-07', 0.00, 'Karangsari', '-6.6917758,108.4964155', 'uploads/1762475195_IMG20251102111027.jpg', 'Branding poster jagung Lilac untuk kiriman ke Pabuaran bersama bandar mas Dion', 2, '2025-11-08 05:29:26', 'approved', '2025-11-07 07:26:35', '2025-11-08 05:29:26', 5, 2),
(255, 5, 5, 1, '2025-11-05', 0.00, 'Cangkring', '-6.6921844,108.5023513', 'uploads/1762475295_IMG20251104160424.jpg', 'Display panenan jagung lilac dikios binaan rizkio tani', 2, '2025-11-08 05:29:18', 'approved', '2025-11-07 07:28:16', '2025-11-08 05:29:18', 5, 2),
(256, 5, 5, 1, '2025-11-07', 0.00, 'Sindanglaut', '-6.6949537,108.4967865', 'uploads/1762475848_IMG20251103130716.jpg', 'Display panenan jagung Lilac dikios binaan sumbertani', 2, '2025-11-08 05:29:12', 'approved', '2025-11-07 07:37:28', '2025-11-08 05:29:12', 5, 2),
(257, 5, 5, 1, '2025-11-07', 0.00, 'Sindang laut', '-6.6921844,108.5023513', 'uploads/1762475966_IMG20251103122139.jpg', 'Display panenan jagung Lilac dikios binaan tanimakmur', 2, '2025-11-08 05:29:07', 'approved', '2025-11-07 07:39:27', '2025-11-08 05:29:07', 5, 2),
(258, 5, 5, 1, '2025-11-03', 0.00, 'Majanghaji', '-6.6901653,108.4967865', 'uploads/1762476096_IMG20251103151843.jpg', 'Display panenan jagung Lilac dikios binaan umi tani', 2, '2025-11-08 05:28:01', 'approved', '2025-11-07 07:41:36', '2025-11-08 05:28:01', 5, 2),
(259, 5, 5, 1, '2025-11-03', 0.00, 'Ciledug', '-6.6901653,108.4967865', 'uploads/1762476179_IMG20251029092628.jpg', 'Display panenan jagung Lilac dikios binaan suciMulyatani', 2, '2025-11-08 05:27:53', 'approved', '2025-11-07 07:42:59', '2025-11-08 05:27:53', 5, 2),
(260, 5, 5, 1, '2025-11-07', 0.00, 'Sumber pabuaran', '-6.6921844,108.5023513', 'uploads/1762476283_IMG20251029114918.jpg', 'Display panenan jagung Lilac dibandar binaan pak opicPabuara untuk dikenalkan ke binannya', 2, '2025-11-08 05:29:03', 'approved', '2025-11-07 07:44:43', '2025-11-08 05:29:03', 5, 2),
(261, 6, 3, 2, '2025-11-07', 750000.00, 'Ds. Sukamukti Kec. Jalaksana Kab. Kuningan', '', 'uploads/1762502132_339D6EC2-109B-487E-88E8-3AF924224B9E.jpeg', '', 2, '2025-11-08 05:26:57', 'approved', '2025-11-07 14:55:32', '2025-11-08 05:26:57', 6, 2),
(262, 7, 7, NULL, '2025-11-07', 0.00, 'Kios cahayatani', '', 'uploads/1762506440_1000608285.jpg', '', 2, '2025-11-08 05:26:51', 'approved', '2025-11-07 16:07:20', '2025-11-08 05:26:51', 7, 2),
(263, 7, 5, 7, '2025-11-07', 0.00, 'Kios cahayatani', '', 'uploads/1762506466_1000608286.jpg', '', 2, '2025-11-08 05:26:44', 'approved', '2025-11-07 16:07:47', '2025-11-08 05:26:44', 7, 2),
(264, 7, 2, 7, '2025-11-07', 300000.00, 'CangkuduCipaku kadipaten', '', 'uploads/1762565996_1000593374.jpg', 'Farmers Meeting (FM) pengenalan produk advanta bersama petani binaan pak idit\r\nProdak fokus lavanta, Beijing, kp.herra ,madu 59 \r\n🌽🥒🫘🍆\r\nBlok cangkudu DS.cipaku kadipaten', 2, '2025-11-11 09:35:53', 'approved', '2025-11-08 08:39:56', '2025-11-11 09:35:53', 7, 2),
(265, 6, 1, 2, '2025-11-10', 300000.00, 'Kios Mandiri Jaya Tani', '-6.9353547484763665,108.48770345264778', 'uploads/1762742290_IMG_1244.jpeg', '', 2, '2025-11-11 09:35:42', 'approved', '2025-11-10 09:38:11', '2025-11-11 09:35:42', 6, 2),
(266, 8, 3, 8, '2025-11-10', 750000.00, 'Desa Nagrak Kecamatan Ciater Subang', '-6.7315717,107.64519', 'uploads/1762762061_PhotoGrid_Plus_1762761827048.jpg', 'Study Banding / Field Trip (FT)\r\nMelihat Hasil Panen Tomat Nona 23 F1 dan Cabai Rawit Shima. Pengenalan all produk Advanta. Fokus Produk Timun Lavanta, Jagung Madu-59, Tomat Nona 23 F1 dan Cabai Rawit Shima bersama Mitra Petani Kang Aji.', 2, '2025-11-11 09:35:20', 'approved', '2025-11-10 15:07:41', '2025-11-11 09:35:20', 8, 2),
(267, 18, 3, 2, '2025-11-10', 783500.00, 'Pasanggrahan Sumedang', '-6.9164964,107.7098343', 'uploads/1762787487_1000529335.webp', 'Field Trip (FT) Jagung Manis Madu-59 F1. 🌽🌽🌽\r\nPengenalan _All Product_ Advanta Fokus Jagung Manis Madu-59 F1, Melihat Hasil Panen, Uji Rasa dan Sharing Teknis Budidaya Jagung Manis Madu-59 F1 Bersama Petani Mitra Raja Tani di Lahan Bu Iyah Pasanggrahan', NULL, NULL, 'not_responded', '2025-11-10 22:11:27', '2025-11-13 20:45:33', 18, 18),
(268, 18, 1, 2, '2025-11-11', 300000.00, 'Pasir Biru Rancakalong Sumedang', '-6.8499506,107.8331197', 'uploads/1762829305_1000530750.webp', 'One Day Promo sekaligus Pengenalan All Produk Advanta di Kios Mekar Tani Pasir Biru, Sumedang.', NULL, NULL, 'not_responded', '2025-11-11 09:48:25', NULL, 18, NULL),
(269, 18, 2, 2, '2025-11-12', 300000.00, 'Haurgombong Sumedang', '-6.8957453,107.8041415', 'uploads/1762932279_1000533987.webp', '_Farmers Meeting_ diskusi sekaligus penyuluhan penanaman Madu 59 F1 dengan menggunakan perlakuan benih dan sosialisasi produk advanta lainnya bersama Petani Haurgombong, Sumedang.', NULL, NULL, 'not_responded', '2025-11-12 14:24:39', NULL, 18, NULL),
(270, 7, 3, 1, '2025-11-12', 750000.00, 'Panyingkiran', '', 'uploads/1762937910_1000614467.jpg', '', 2, '2025-11-12 17:21:21', 'approved', '2025-11-12 15:58:30', '2025-11-12 17:21:21', 7, 2),
(271, 5, 3, 1, '2025-11-12', 750000.00, 'Weru dan megu', '-6.6926495,108.4970352', 'uploads/1762968785_Picsart_25-11-12_13-39-22-366.jpg', 'Fieldtrip melihat tanaman jagung manis madu dilahan mang likun dan melihat Lilac dilahan mas gandi sekaligus proses pemetikan panen Lilac dan madu bersama petani binaan mas Hadi, bandar mas muldoko serta petani binaan ppl pamijahan menuju Megu dan weru', 2, '2025-11-13 12:18:46', 'approved', '2025-11-13 00:33:06', '2025-11-13 12:18:46', 5, 2),
(272, 5, 7, NULL, '2025-11-12', 0.00, 'Cirebon', '-6.6926495,108.4970352', 'uploads/1762968929_IMG20251112092850.jpg', 'Branding untuk kiriman pasar jagung ketan diwilayah Jawa tengah', 2, '2025-11-13 12:18:42', 'approved', '2025-11-13 00:35:29', '2025-11-13 12:18:42', 5, 2),
(273, 5, 7, NULL, '2025-11-12', 0.00, 'Cirebon', '-6.6926495,108.4970352', 'uploads/1762969090_IMG-20251113-WA0001.jpg', 'Kloter pengiriman ke 2 branding poster Lilac untuk kirim panenan kewilayah gebang', 2, '2025-11-13 12:18:32', 'approved', '2025-11-13 00:38:10', '2025-11-13 12:18:32', 5, 2),
(274, 6, 2, 8, '2025-11-14', 300000.00, 'Ds. Cisantana Kec. Cigugur Kab. Kuningan', '', 'uploads/1763111067_39FAFDAF-17E3-4B85-825D-E87D67FDC7B9.jpeg', '', 2, '2025-11-16 15:58:58', 'approved', '2025-11-14 16:04:27', '2025-11-16 15:58:58', 6, 2),
(275, 7, 2, 7, '2025-11-16', 300000.00, 'SukamulyaKertajati', '', 'uploads/1763275475_1000615664.jpg', '', 2, '2025-11-16 15:58:44', 'approved', '2025-11-16 13:44:35', '2025-11-16 15:58:44', 7, 2),
(276, 8, 5, 8, '2025-11-17', 0.00, 'Ciater, Subang', '-6.737533,107.6704688', 'uploads/1763351905_20251117_105343.jpg', 'Kios Bumi Hijau Makmur', 2, '2025-11-20 09:39:13', 'approved', '2025-11-17 10:58:26', '2025-11-20 09:39:13', 8, 2),
(277, 8, 5, 11, '2025-11-17', 0.00, 'Ciater, Subang', '-6.7374699,107.6704589', 'uploads/1763351945_20251117_105443.jpg', 'Kios Bumi Hijau Makmur', 2, '2025-11-20 09:39:09', 'approved', '2025-11-17 10:59:05', '2025-11-20 09:39:09', 8, 2),
(278, 8, 5, 8, '2025-11-17', 0.00, 'Wanayasa, Purwakarta', '-6.6819624,107.5623312', 'uploads/1763355405_20251117_115246.jpg', 'Kios Fajar Tani Mandiri', 2, '2025-11-20 09:39:07', 'approved', '2025-11-17 11:56:45', '2025-11-20 09:39:07', 8, 2),
(279, 8, 5, 11, '2025-11-17', 0.00, 'Wanayasa, Purwakarta', '-6.6819803,107.562323', 'uploads/1763355452_20251117_115146.jpg', 'Kios Fajar Tani Mandiri', 2, '2025-11-20 09:39:03', 'approved', '2025-11-17 11:57:33', '2025-11-20 09:39:03', 8, 2),
(280, 8, 2, 8, '2025-11-17', 300000.00, 'Desa Pasanggrahan, Kec. Bojong, Purwakarta', '-6.7288589,107.53073', 'uploads/1763364765_20251117_142459.jpg', 'Farmer Meeting (FM)\r\nPengenalan produk Advanta. Fokus Produk Jagung Madu-59, Cabai Rawit Shima, Tomat Nona 23 F1, dan Timun Lavanta bersama Petani binaan Pak Endih.\r\nKecamatan Bojong, Purwakarta.', 2, '2025-11-20 09:14:53', 'approved', '2025-11-17 14:32:45', '2025-11-20 09:14:53', 8, 2),
(281, 7, 1, 6, '2025-11-10', 300000.00, 'Kios cahayatani', '', 'uploads/1763371348_1000621475.jpg', 'ODP kios CAHAYATANI \r\n🌽🥒🫘\r\nPANYINGKIRAN', 2, '2025-11-20 09:13:32', 'approved', '2025-11-17 16:22:28', '2025-11-20 09:13:32', 7, 2),
(282, 8, 2, 2, '2025-11-18', 1250000.00, 'Darangdan, Purwakarta', '-6.6743483,107.4222217', 'uploads/1763443041_PhotoGrid_Plus_1763442434708.jpg', 'Big Farmer Meeting (FM)\r\nPengenalan produk Advanta. Fokus Produk Jagung Madu-59, Cabai Rawit Shima, dan Timun Lavanta bersama Mitra Petani binaan Elevarm.\r\nKecamatan Darangdan, Purwakarta.', 2, '2025-11-20 09:13:19', 'approved', '2025-11-18 12:17:21', '2025-11-20 09:13:19', 8, 2),
(283, 5, 1, 2, '2025-11-19', 300000.00, 'Sindanglaut', '-6.692656,108.4970483', 'uploads/1763553588_Picsart_25-11-19_09-31-38-328.jpg', 'Odp kios tani makmur produk fokus KCP herra, madu dan lavanta dicirebon', 2, '2025-11-20 09:12:15', 'approved', '2025-11-19 18:59:49', '2025-11-20 09:12:15', 5, 2),
(284, 8, 2, 7, '2025-11-20', 300000.00, 'Ds. Wanasari Kec. Wanayasa Purwakarta', '-6.6572317,107.5431467', 'uploads/1763624462_20251120_141850.jpg', 'Farmer Meeting (FM)\r\nPengenalan produk Advanta. Fokus Produk Jagung Madu-59, Cabai Rawit Shima, Tomat Nona 23 F1, Timun Lavanta, dan KCP Herra 22 bersama Petani binaan Pak H Omin.\r\nKecamatan Wanayasa, Purwakarta.', 2, '2025-11-24 17:25:59', 'approved', '2025-11-20 14:41:03', '2025-11-24 17:25:59', 8, 2),
(285, 6, 5, 8, '2025-11-20', 0.00, 'Kios Pratama Tani', '', 'uploads/1763626378_IMG_1408.jpeg', '', 2, '2025-11-24 17:25:51', 'approved', '2025-11-20 15:12:59', '2025-11-24 17:25:51', 6, 2),
(286, 6, 5, 8, '2025-11-20', 0.00, 'Selamat Tani', '', 'uploads/1763626495_IMG_1409.jpeg', '', 2, '2025-11-24 17:25:49', 'approved', '2025-11-20 15:14:56', '2025-11-24 17:25:49', 6, 2),
(287, 6, 5, 8, '2025-11-20', 0.00, 'Wajam Tani', '', 'uploads/1763626712_IMG-20251120-WA0019.jpg', '', 2, '2025-11-24 17:25:45', 'approved', '2025-11-20 15:18:33', '2025-11-24 17:25:46', 6, 2),
(288, 6, 5, 8, '2025-11-20', 0.00, 'Agro Tani', '', 'uploads/1763626799_IMG-20251120-WA0020.jpg', '', 2, '2025-11-24 17:25:42', 'approved', '2025-11-20 15:19:59', '2025-11-24 17:25:42', 6, 2),
(289, 6, 5, 8, '2025-11-20', 0.00, 'Ukim Tani', '', 'uploads/1763626888_IMG-20251120-WA0021.jpg', '', 2, '2025-11-24 17:25:39', 'approved', '2025-11-20 15:21:29', '2025-11-24 17:25:39', 6, 2),
(290, 6, 3, 8, '2025-11-20', 750000.00, 'Ds. Tejamulya Kec. Argapura Kab. Majalengka', '', 'uploads/1763635147_93E410C9-BE5F-4ED7-9F74-34D583CC14C1.jpeg', '', 2, '2025-11-24 17:25:35', 'approved', '2025-11-20 17:39:07', '2025-11-24 17:25:35', 6, 2),
(291, 6, 2, 2, '2025-11-21', 300000.00, 'Ds. Peusing Kec. Jalaksana Kab. Kuningan', '', 'uploads/1763713522_EE61DCE2-E4D6-4F6D-A1DE-E0D3EDEFF4C7.jpeg', '', 2, '2025-11-24 17:25:32', 'approved', '2025-11-21 15:25:22', '2025-11-24 17:25:32', 6, 2),
(292, 15, 2, 8, '2025-11-23', 300000.00, 'Kampung Cilangla, Warjabakti, Kec. Cimaung.', '', 'uploads/1763900624_IMG_20251121_205913.jpg', 'Farmer Meeting pengenalan tomat nona 23 F1,kelompok tani,pak uus', NULL, NULL, 'not_responded', '2025-11-23 19:23:45', NULL, 15, NULL),
(293, 15, 3, 2, '2025-11-20', 800000.00, 'jaganaya,Bugel,Neglasari,Cimaung', '', 'uploads/1763900786_IMG_20251120_133039_933.webp', 'Fild trip petani binaan pak ozen batu numpuk, Sindang panon,ke lahan jagung manis pak iyep melihat performa tanaman sekaligus diskusi perawatan jagung manis madu 59 F1.', NULL, NULL, 'not_responded', '2025-11-23 19:26:26', NULL, 15, NULL),
(294, 7, 2, 7, '2025-11-21', 300000.00, 'Wanasalam jatitujuh', '', 'uploads/1763940422_1000612129.jpg', '', 2, '2025-11-24 17:25:26', 'approved', '2025-11-24 06:27:02', '2025-11-24 17:25:26', 7, 2),
(295, 5, 2, 4, '2025-11-22', 300000.00, 'Pabuaran', '-6.829541,108.6298812', 'uploads/1763957089_IMG-20251122-WA0010.jpg', 'Farmer meteeng bersama petani dan kelompok tani binaan pak Opik diwilayah pabuaran Cirebon mengenalkan jagung Lilac, Reva dan menginfokan jagung h72 sekaligus ajak untuk tanam diwilayah Cirebon.', 2, '2025-11-24 17:25:21', 'approved', '2025-11-24 11:04:50', '2025-11-24 17:25:21', 5, 2),
(296, 8, 2, 6, '2025-11-24', 300000.00, 'Ds. Palasari Kec. Ciater Subang', '-6.7106383,107.662925', 'uploads/1763971575_20251124_145708.jpg', 'Farmer Meeting (FM)\r\nPengenalan produk Advanta. Fokus Produk Jagung Madu-59, Cabai Rawit Shima, Tomat Nona 23 F1, Timun Lavanta dan KCP Herra 22 bersama Petani binaan Pak Eman.\r\nKecamatan Ciater, Subang.', 2, '2025-11-24 17:25:13', 'approved', '2025-11-24 15:06:15', '2025-11-24 17:25:13', 8, 2),
(297, 19, 1, 6, '2025-11-04', 300000.00, 'Kios Berkah Tani,Margaluyu-Cipatat', '', 'uploads/1763988026_1000440780.jpg', 'Petani menaruh harapan besar terhadap lavanta selaku newcomer timun di wilayah tersebut. Petani yang datang ke kios utk berbelanja, beberapa diantaranya tertarik terhadap timun lavanta ini.', NULL, NULL, 'not_responded', '2025-11-24 19:40:26', NULL, 19, NULL),
(298, 19, 4, 6, '2025-11-10', 800000.00, 'Pangkalan-Cikalong', '', 'uploads/1763988185_1000457874.jpg', 'Pergeseran minat terhadap varietas timun baru di daerah ini msh besar karena petani merasakan belum ada varietas yg konsisten terhadap kualitas. Petani mengharapkan lavanta bisa menjadi solusi.', NULL, NULL, 'not_responded', '2025-11-24 19:43:05', NULL, 19, NULL),
(299, 19, 5, 2, '2025-10-27', 30000.00, 'Berkah tani-Cipatat\r\nSolusi Tani-Lembang', '', 'uploads/1763988588_1000442870.jpg', 'Display rebusan jagung madu perlu terus diperkenalkan agar petani lebih yakin kalau jagung madu memang semanis madu.', NULL, NULL, 'not_responded', '2025-11-24 19:49:48', NULL, 19, NULL),
(300, 6, 7, NULL, '2025-11-25', 0.00, 'Kios Mandiri Jaya Tani', '', 'uploads/1764042847_dd49c17e-70d6-4004-8bb3-560780385539.jpeg', '', 2, '2025-11-27 07:00:04', 'approved', '2025-11-25 10:54:07', '2025-11-27 07:00:04', 6, 2),
(301, 6, 7, NULL, '2025-11-25', 0.00, 'Pratama Tani', '', 'uploads/1764050840_IMG-20251125-WA0044.jpg', '', 2, '2025-11-27 07:00:06', 'approved', '2025-11-25 13:07:20', '2025-11-27 07:00:06', 6, 2),
(302, 8, 2, 6, '2025-11-25', 300000.00, 'Ds. Cisaat Kec. Ciater, Subang', '', 'uploads/1764053192_20251124_145631.jpg', 'Farmer Meeting (FM)\r\nPengenalan produk Advanta. Fokus Produk Jagung Madu-59, Cabai Rawit Shima, Tomat Nona 23 F1, Timun Lavanta, dan KCP Herra 22 bersama Petani binaan Pak Apit.\r\nKecamatan Ciater, Subang.', 2, '2025-11-27 06:59:49', 'approved', '2025-11-25 13:46:32', '2025-11-27 06:59:49', 8, 2),
(303, 8, 8, NULL, '2025-11-25', 0.00, '', '', 'uploads/1764056643_20251125_104308.jpg', '', 2, '2025-11-27 06:59:34', 'approved', '2025-11-25 14:44:04', '2025-11-27 06:59:34', 8, 2),
(304, 5, 8, NULL, '2025-11-25', 0.00, 'Cirebon', '-6.7008387,108.4936346', 'uploads/1764058887_IMG20251125151256.jpg', 'Reporting bulan November 2025', 2, '2025-11-27 06:59:29', 'approved', '2025-11-25 15:21:27', '2025-11-27 06:59:29', 5, 2),
(305, 6, 2, 2, '2025-11-25', 300000.00, 'Ds. Padarek Kec. Kuningan Kab. Kuningan', '', 'uploads/1764061595_C87FCDA3-11F8-4D82-95F9-7A320D426D25.jpeg', '', 2, '2025-11-27 06:59:24', 'approved', '2025-11-25 16:06:35', '2025-11-27 06:59:24', 6, 2),
(306, 7, 8, NULL, '2025-11-25', 0.00, 'Majalengka', '', 'uploads/1764111906_1000632744.jpg', '', 2, '2025-11-27 06:59:12', 'approved', '2025-11-26 06:05:07', '2025-11-27 06:59:12', 7, 2),
(307, 16, 3, 2, '2025-11-26', 1300000.00, 'Lahan aic', '', 'uploads/1764119613_IMG_0657.jpeg', 'Fleld trif madu 2 kampung cisaat dan cinisti', NULL, NULL, 'not_responded', '2025-11-26 08:13:33', NULL, 16, NULL),
(308, 16, 3, 13, '2025-11-26', 800000.00, 'Lahan Aic', '', 'uploads/1764119702_IMG_0743.jpeg', 'Perani toblong pasirwangi 1 rombongan', NULL, NULL, 'not_responded', '2025-11-26 08:15:03', NULL, 16, NULL),
(309, 18, 2, 2, '2025-11-26', 300000.00, 'Tanjungsari Sumedang', '-6.9128858,107.8033379', 'uploads/1764158782_1000562209.webp', '_Farmers Meeting_ Pengenalan Produk Advanta Bersama Petani Dsn. Sirah Cikandang Kec. Tanjungsari Sumedang.', NULL, NULL, 'not_responded', '2025-11-26 19:06:22', NULL, 18, NULL),
(310, 6, 7, NULL, '2025-11-27', 0.00, 'Kios Barokah Tani Jaya', '', 'uploads/1764207049_IMG_1667.jpeg', '', 2, '2025-11-27 12:46:53', 'approved', '2025-11-27 08:30:49', '2025-11-27 12:46:53', 6, 2),
(311, 8, 5, 6, '2025-12-01', 0.00, 'Ciater, Subang', '-6.7374892,107.6704777', 'uploads/1764216360_20251127_103139.jpg', 'Kios Bumi Hijau Makmur', 2, '2025-12-16 18:12:20', 'approved', '2025-11-27 11:06:01', '2025-12-16 18:12:20', 8, 2),
(312, 6, 8, NULL, '2025-11-27', 0.00, '', '', 'uploads/1764219040_img_20251127_114927_2099718500758095882.jpg', '', 2, '2025-11-27 12:46:47', 'approved', '2025-11-27 11:50:41', '2025-11-27 12:46:47', 6, 2),
(313, 8, 5, 6, '2025-12-01', 0.00, 'Wanayasa, Purwakarta', '-6.6819911,107.5623263', 'uploads/1764224476_20251127_123942.jpg', 'Kios Fajar Tani Mandiri', 2, '2025-12-16 18:12:16', 'approved', '2025-11-27 13:21:17', '2025-12-16 18:12:16', 8, 2),
(314, 8, 2, 8, '2025-12-01', 300000.00, 'Ds. Pasanggrahan Kec. Bojong Purwakarta', '', 'uploads/1764570153_20251128_135444.jpg', 'Farmer Meeting (FM)\r\nPengenalan produk Advanta. Fokus Produk Jagung Madu-59, Cabai Rawit Shima, Tomat Nona 23 F1, dan Timun Lavanta bersama Petani binaan Kang Miftah.\r\nKecamatan Bojong, Purwakarta.', 2, '2025-12-05 20:20:06', 'approved', '2025-12-01 13:22:34', '2025-12-05 20:20:06', 8, 2),
(315, 7, 2, 2, '2025-12-01', 300000.00, 'Mirat lewimunding', '', 'uploads/1764580430_1000625213.jpg', 'Farmer Meeting (FM)\r\nPengenalan produk Advanta. Fokus Produk Jagung Madu, Lilac , Shima, Timun Lavanta dan kp.herra bersama petani DS . Mirat\r\nLewimunding', 2, '2025-12-05 20:19:59', 'approved', '2025-12-01 16:13:50', '2025-12-05 20:19:59', 7, 2),
(316, 6, 1, 8, '2025-12-01', 300000.00, 'Mustika Mulya Tani', '', 'uploads/1764604676_IMG_1766.jpeg', '', 2, '2025-12-05 20:19:51', 'approved', '2025-12-01 22:57:56', '2025-12-05 20:19:51', 6, 2),
(317, 8, 2, 6, '2025-12-04', 300000.00, 'Ds. Cisaat Kec. Ciater Subang', '', NULL, 'Farmer Meeting (FM)\r\nPengenalan produk Advanta. Fokus Produk Jagung Madu-59, Cabai Rawit Shima, Tomat Nona 23 F1, Timun Lavanta dan KCP Herra 22 bersama Petani binaan Pak Yana.\r\nKecamatan Ciater, Subang.', 2, '2025-12-05 20:19:45', 'approved', '2025-12-04 14:03:35', '2025-12-05 20:19:45', 8, 2),
(318, 6, 4, 8, '2025-12-04', 1500000.00, 'Ds. Cipulus Kec. Cikijing Kab. Majalengka', '', 'uploads/1764843766_673DAD19-0427-4539-B942-3323F82F2C1E.jpeg', '', 2, '2025-12-05 20:19:26', 'approved', '2025-12-04 17:22:46', '2025-12-05 20:19:26', 6, 2),
(319, 6, 2, 8, '2025-12-05', 300000.00, 'Ds. Cibunut Kec. Argapura Kab. Majalengka', '', 'uploads/1764922167_FD0AFE55-64C8-4AC9-8609-9AEF1603030B.jpeg', '', 2, '2025-12-05 20:19:15', 'approved', '2025-12-05 15:09:27', '2025-12-05 20:19:15', 6, 2),
(320, 7, 1, 7, '2025-12-03', 300000.00, 'Kios sobatani', '', 'uploads/1764943328_1000645731.jpg', '', 2, '2025-12-16 18:12:03', 'approved', '2025-12-05 21:02:08', '2025-12-16 18:12:03', 7, 2),
(321, 6, 2, 9, '2025-12-12', 300000.00, 'Ds. Argamukti Kec. Argapura Kab. Majalengka', '', 'uploads/1765541697_IMG-20251212-WA0028.jpg', '', 2, '2025-12-16 18:11:55', 'approved', '2025-12-12 19:14:57', '2025-12-16 18:11:55', 6, 2),
(322, 6, 7, NULL, '2025-12-15', 0.00, 'Persemaian Benih Dinar Tani', '', 'uploads/1765776180_IMG-20251215-WA0009.jpg', '', 2, '2025-12-16 18:11:45', 'approved', '2025-12-15 12:23:01', '2025-12-16 18:11:45', 6, 2),
(323, 7, 2, 1, '2025-12-06', 300000.00, 'Kadipaten', '', 'uploads/1765921990_1000636757.jpg', 'Farmers Meeting (FM) pengenalan produk advanta bersama petani Ds. Kadipaten\r\n🌽🥒🫘🌶️\r\nMajalengka', 2, '2025-12-25 19:45:22', 'approved', '2025-12-17 04:53:10', '2025-12-25 19:45:22', 7, 2),
(324, 7, 3, NULL, '2025-12-16', 750000.00, 'Girimukti', '', 'uploads/1765922662_1000657519.jpg', 'Field Trip (FT) melihat perform kp.herra 22 di lahan pak Daman\r\nBersama mitra petani pak idit dan pak asep, respon petani bagus terhadap umur genjah, kelebatan dan produksi buah, siap mencoba di musim selanjutnya,\r\n🥒🫘🫘🥒 \r\nGirimukti kasokandel', 2, '2025-12-25 19:45:18', 'approved', '2025-12-17 05:04:23', '2025-12-25 19:45:18', 7, 2),
(325, 7, 7, NULL, '2025-12-16', 0.00, 'Kios cahayatani', '', 'uploads/1765922838_1000658529.jpg', 'Brandingkp.herra', 2, '2025-12-25 19:45:14', 'approved', '2025-12-17 05:07:18', '2025-12-25 19:45:14', 7, 2),
(326, 7, 5, 7, '2025-12-16', 0.00, 'Kios cahayatani', '', 'uploads/1765922863_1000658529.jpg', '', 2, '2025-12-25 19:45:10', 'approved', '2025-12-17 05:07:43', '2025-12-25 19:45:10', 7, 2),
(327, 18, 4, 2, '2025-12-16', 1817000.00, 'Lahan JM Madu-59 Milik Pak Acek Tanjungsari Sumedang', '', 'uploads/1766063937_1000598184.webp', 'Big Fieldtrip ini dilaksanakan untuk mengembalikan kepercayaan petani dan bandar jagung manis terhadap JM Madu-59 dibalik permasalahan daya tumbuh yang terjadi belakangan. Alhamdulillah peserta mulai percaya kembali untuk menanam produk advanta.', NULL, NULL, 'not_responded', '2025-12-18 20:18:57', NULL, 18, NULL),
(328, 7, 4, 7, '2025-12-19', 1500000.00, 'Ligung', '', 'uploads/1766147482_1000662201.webp', 'Big Field Trip (FT)\r\nMelihat perform kp herra 22 dan pengenalan all produk Advanta. Fokus Produk kacang panjang Herra 22 ,Timun Lavanta, Jagung Lilac dan Madu-59,  \r\nbersama Mitra Petani pak Iwan, RT Wiwin, mas Radita dan bos wardi\r\nLigung\r\nTerimakasih suppor', 2, '2025-12-25 19:45:03', 'approved', '2025-12-19 19:31:23', '2025-12-25 19:45:03', 7, 2),
(329, 8, 4, 2, '2025-12-19', 1500000.00, 'Ds. Ciater Kec. Ciater Subang', '', 'uploads/1766157717_PhotoGrid_Plus_1766132222450.jpg', 'Big FT Petani Kang Ujang', 9, '2025-12-25 19:53:25', 'approved', '2025-12-19 22:21:57', '2025-12-25 19:53:25', 8, 9),
(330, 5, 4, 2, '2025-12-17', 1500000.00, 'Waled, cikulak', '-6.6926433,108.4970053', 'uploads/1766364950_IMG-20251217-WA0136.jpg', 'Big Field Trip, melihat performa tanaman jagung manis madu 59🌽🌽 umur 68-69 hst sekaligus atur jadwal panen besok  dan melihat jagung Reva🌽🌽 di lahan pak erwan, respon baik terhadap performa pertumbuhan jagung madu yang saat ini, ketahanan kresek aman,', 2, '2025-12-25 19:44:55', 'approved', '2025-12-22 07:55:50', '2025-12-25 19:44:55', 5, 2),
(331, 5, 2, 4, '2025-12-01', 300000.00, 'Jatirenggang pabuaran', '-6.6926665,108.4970817', 'uploads/1766365267_IMG-20251201-WA0013.jpg', 'Farmer meteeng bersama petani binaan pa endang mengenalkan benih jagung Reva dan h72 diwilayah pabuaran dan ajak binannya untuk menanam benih advanta dicirebon', 2, '2025-12-25 19:44:51', 'approved', '2025-12-22 08:01:08', '2025-12-25 19:44:51', 5, 2),
(332, 5, 3, 4, '2025-12-05', 750000.00, 'Jatirenggang', '-6.6926607,108.4970524', 'uploads/1766365358_IMG-20251205-WA0019.jpg', 'Fieldtrip bersama binaan bandar pak Nasir dan binaan kios berkah Mulya tanu dilahan pa Nana melihat jagung Reva, madu dan kompetitor, sekaligus mengenalkan jagung Gendhis 72 petani wilayah jatirenggang respon bagus\r\nKondisi jagung walaupun terguyur hujan p', 2, '2025-12-25 19:44:47', 'approved', '2025-12-22 08:02:38', '2025-12-25 19:44:47', 5, 2),
(333, 5, 2, 4, '2025-12-13', 300000.00, 'Gebang kulon', '-6.6926205,108.4971921', 'uploads/1766365490_IMG-20251213-WA0014.jpg', 'Farmer meteeng diwilayah gebang kulon bersama petani binaan mang Komar dan bos Imin binaan pak haji Solihin menginfokan sekaligus mengenalkan jagung h72 diwilayah gebang dan ajak tanam kembali dimusim ini dan musim berikutnya, gebang, Cirebon', 2, '2025-12-25 19:44:27', 'approved', '2025-12-22 08:04:50', '2025-12-25 19:44:27', 5, 2),
(334, 5, 2, 4, '2025-12-16', 300000.00, 'Jatirenggang', '-6.6926728,108.4970662', 'uploads/1766365599_IMG-20251216-WA0016.jpg', 'Farmer meteeng dibinaan pak Tamin mengenalkan benih jagung advanta, jagung manis madu, jagyng Reva, jagung h72 dan tanaman timun lavanta serta kcp herra diwilayah jatirenggang Pabuaran lor Cirebon dan ajak tanam diawal tahun setelah panen bawang', 2, '2025-12-25 19:44:05', 'approved', '2025-12-22 08:06:40', '2025-12-25 19:44:05', 5, 2),
(335, 5, 1, 7, '2025-12-02', 300000.00, 'Sindanglaut', '-6.6926728,108.4970662', 'uploads/1766366010_Picsart_25-11-28_09-18-54-426.jpg', 'Odp dikios sumber tani krop produk fokus jagung manis madu,KCP herra, timun lavanta, timun Gogor dan cabe rawit Shima untuk dongkrak penanaman ditahun baru,Cirebon', 2, '2025-12-25 19:43:59', 'approved', '2025-12-22 08:13:31', '2025-12-25 19:43:59', 5, 2),
(336, 6, 2, 8, '2025-12-22', 300000.00, 'Ds. Sagarahiang Kec. Darma Kab. Kuningan', '', 'uploads/1766399165_4A4D40BD-13B5-413C-9BC7-A6D15F16A936.jpeg', '', 2, '2025-12-24 11:26:55', 'approved', '2025-12-22 17:26:05', '2025-12-24 11:26:55', 6, 2),
(337, 7, 3, 7, '2025-12-18', 750000.00, 'H. Abay', '', 'uploads/1766462766_1000666837.jpg', '', 2, '2025-12-24 11:26:49', 'approved', '2025-12-23 11:06:07', '2025-12-24 11:26:49', 7, 2),
(338, 6, 3, 7, '2025-12-23', 750000.00, 'Ds. Jalaksana Kec. Jalaksana Kab. Kuningan', '', 'uploads/1766488424_F09154AB-87D4-4196-B8F6-1E5F64A7ABBC.jpeg', '', 2, '2025-12-24 11:26:17', 'approved', '2025-12-23 18:13:44', '2025-12-24 11:26:17', 6, 2),
(339, 7, 2, 7, '2025-12-18', 300000.00, 'Sukagumiwang', '', 'uploads/1766541756_1000667191.jpg', '', 2, '2025-12-24 11:26:11', 'approved', '2025-12-24 09:02:36', '2025-12-24 11:26:11', 7, 2),
(340, 6, 3, 9, '2025-12-24', 750000.00, 'Ds. Argalingga Kec. Argapura Kab. Majalengka', '', 'uploads/1766572945_CDC43027-95B0-4C49-85D4-9A214DEC8A9B.jpeg', '', 2, '2026-01-05 07:14:19', 'rejected', '2025-12-24 17:42:25', '2026-01-05 07:14:19', 6, 2),
(341, 6, 8, NULL, '2025-12-24', 0.00, '', '', NULL, '', 2, '2025-12-25 19:43:01', 'approved', '2025-12-24 17:43:46', '2025-12-25 19:43:01', 6, 2),
(342, 8, 2, 8, '2025-12-24', 300000.00, 'Ds. Palasari Kec. Ciater, Subang', '', 'uploads/1766579735_20251221_113345.jpg', 'Farmer Meeting (FM)\r\nPengenalan produk Advanta. Fokus Produk Jagung Madu-59, Cabai Rawit Shima, Tomat Nona 23 F1, dan Timun Lavanta bersama Petani binaan Pak Engkos.\r\nKecamatan Ciater, Subang.', 2, '2025-12-25 19:42:53', 'approved', '2025-12-24 19:35:35', '2025-12-25 19:42:53', 8, 2),
(343, 5, 5, 2, '2025-12-22', 0.00, 'Pabedilan', '-6.501195,107.4707753', 'uploads/1766668860_IMG20251222144741.jpg', 'Display panenan jagung manis madu dan Lilac dikios suci Mulyatani', 2, '2025-12-29 11:36:52', 'approved', '2025-12-25 20:21:01', '2025-12-29 11:36:52', 5, 2),
(344, 5, 5, 2, '2025-12-19', 0.00, 'Matanghaji', '-6.5011902,107.470779', 'uploads/1766669004_IMG20251219154759.jpg', 'Display panenan jagung manis madu dikios umi tani', 2, '2025-12-29 11:36:49', 'approved', '2025-12-25 20:23:24', '2025-12-29 11:36:49', 5, 2),
(345, 5, 5, 2, '2025-12-02', 0.00, 'Sindanglaut', '-6.5011826,107.470762', 'uploads/1766669199_IMG20251128091025.jpg', 'Display panenan jagung manis madu sekaligus odp dikios sumber tani cirebon', 2, '2025-12-29 11:36:47', 'approved', '2025-12-25 20:26:39', '2025-12-29 11:36:47', 5, 2),
(346, 8, 8, NULL, '2025-12-25', 0.00, 'Purwakarta', '', 'uploads/1766669276_20251225_202700.jpg', '', 2, '2025-12-29 11:36:43', 'approved', '2025-12-25 20:27:58', '2025-12-29 11:36:43', 8, 2),
(347, 5, 5, 1, '2025-12-18', 0.00, 'Waled', '-6.5011818,107.4707686', 'uploads/1766669320_IMG20251218130222.jpg', 'Display panenan jagung manis madu dan Lilac dikios berkah Mulyatani', 2, '2025-12-29 11:36:39', 'approved', '2025-12-25 20:28:41', '2025-12-29 11:36:39', 5, 2);
INSERT INTO `activities` (`id`, `user_id`, `type_id`, `product_id`, `date`, `cost`, `location`, `latlong`, `image_path`, `notes`, `responded_by_id`, `responded_datetime`, `status`, `created_datetime`, `updated_datetime`, `created_by_uid`, `updated_by_uid`) VALUES
(348, 5, 7, NULL, '2025-12-25', 0.00, 'Weru', '-6.5011948,107.4707722', 'uploads/1766669810_IMG20251220104959.jpg', 'Kawal panenan untuk Pasar Palimanan sekaligus branding poster agar lebih luas penyebarannya', 2, '2025-12-29 11:36:36', 'approved', '2025-12-25 20:36:51', '2025-12-29 11:36:36', 5, 2),
(349, 5, 7, NULL, '2025-12-25', 0.00, 'Weru', '-6.5011739,107.470747', 'uploads/1766669966_IMG20251220122734.jpg', 'Branding panenan Lilac untuk disebarkan kepengecer diwilayah Cirebon timur', 2, '2025-12-29 11:36:33', 'approved', '2025-12-25 20:39:26', '2025-12-29 11:36:33', 5, 2),
(350, 5, 8, NULL, '2025-12-26', 0.00, '', '-6.470525,107.4822902', 'uploads/1766716949_IMG-20251226-WA0015.jpg', 'Kirim berkas absen', 2, '2025-12-29 11:36:29', 'approved', '2025-12-26 09:42:29', '2025-12-29 11:36:29', 5, 2),
(351, 8, 4, 2, '2025-12-27', 0.00, 'Ds. Cibungur Kec. Bungursari Purwakarta', '-6.4639343,107.4894708', 'uploads/1766825918_IMG-20251227-WA0034.jpg', 'Harvest Festival', 2, '2025-12-29 11:36:25', 'approved', '2025-12-27 15:58:39', '2025-12-29 11:36:25', 8, 2),
(352, 6, 2, 13, '2026-01-09', 300000.00, 'Ds. Sangiang Kec. Banjaran Kab. Majalengka', '-6.949469177942856,108.34500260305582', 'uploads/1767952974_F370ACF9-A0D1-48F1-85F4-4261A26EDF35.jpeg', '', 2, '2026-01-15 19:38:34', 'approved', '2026-01-09 17:02:54', '2026-01-15 19:38:34', 6, 2),
(353, 7, 2, 18, '2026-01-09', 300000.00, 'Leuwihieum cijurey', '', 'uploads/1768481811_1000685994.jpg', '', 2, '2026-01-17 12:35:43', 'approved', '2026-01-15 19:56:51', '2026-01-17 12:35:43', 7, 2),
(354, 8, 3, 2, '2026-01-19', 750000.00, 'Ds. Palasari Kec. Ciater Subang', '', 'uploads/1768805108_PhotoGrid_Plus_1768804852672.jpg', 'Study Banding / Field Trip (FT)\r\nMelihat Hasil Panen Jagung Manis Madu-59 F1 dan pengenalan all produk Advanta. Fokus Produk Timun Lavanta, Jagung Madu-59, Tomat Nona 23 F1 dan Cabai Rawit Shima bersama Mitra Petani Kang Andri.\r\nKecamatan Ciater, Subang.', 2, '2026-01-20 09:08:00', 'approved', '2026-01-19 13:45:08', '2026-01-20 09:08:00', 8, 2),
(355, 8, 2, 8, '2026-01-19', 300000.00, 'Ds. Cibitung Kec. Ciater Subang', '', 'uploads/1768817532_20260107_135524.jpg', 'Farmer Meeting (FM)\r\nPengenalan all produk Advanta. Fokus Produk Jagung Madu-59, Tomat Nona 23 F1, Cabai Rawit Shima dan Timun Lavanta bersama Mitra Petani Pak Kahdi.\r\nKecamatan Ciater, Subang.', 2, '2026-01-20 09:07:56', 'approved', '2026-01-19 17:12:12', '2026-01-20 09:07:56', 8, 2),
(356, 7, 2, 18, '2026-01-16', 300000.00, 'Blok Parunggawul  desa bonang', '', 'uploads/1768875453_1000576699.jpg', '', 2, '2026-01-20 09:40:10', 'approved', '2026-01-20 09:17:33', '2026-01-20 09:40:10', 7, 2),
(357, 5, 2, 18, '2026-01-14', 300000.00, 'Pabuaran', '-6.6926753,108.4978279', 'uploads/1768875758_IMG-20260114-WA0009.jpg', 'Farmer meteeng sekaligus kawal panenan Lilac dibinaan pak haji topik dan mengenalkan jagung h72 Alhamdulillah respon bagus mau mencoba 4 bungkus h72 dan lanjut order untuk tanam Lilac kembali dicirebon', 2, '2026-01-20 09:39:59', 'approved', '2026-01-20 09:22:39', '2026-01-20 09:39:59', 5, 2),
(358, 5, 2, 18, '2026-01-15', 300000.00, 'Gebang-pangenan', '-6.6926753,108.4978279', 'uploads/1768875941_IMG-20260115-WA0018.jpg', 'Farmer meteeng bersama Binaan bandar pak sihab dan pak tayad mengenalkan benih h-72, Reva, madu, Lilac dan benih sayuran\r\nMencoba tanam lavanta 2 pcs, Beijing 7 pcs dibinannya, sekaligus ajak tanam jagung h72 dipangenan', 2, '2026-01-20 09:39:55', 'approved', '2026-01-20 09:25:41', '2026-01-20 09:39:55', 5, 2),
(359, 5, 3, 4, '2026-01-01', 750000.00, 'Waled', '-6.6926753,108.4978279', 'uploads/1768876210_IMG-20251228-WA0030.jpg', 'Field trip ditanamam jagung Reva mang Irman, bersama binaan bandar lapak h.oka mengenalkan jagung h72 dan ajak tanam dimt pertama diwilayah Cirebon, sekaligus kawal penanaman jagung manis madu 25 bungkus dilahan mas Erwan', 2, '2026-01-20 09:39:50', 'approved', '2026-01-20 09:30:10', '2026-01-20 09:39:50', 5, 2),
(360, 5, 3, 2, '2026-01-03', 750000.00, 'Sumber', '-6.6926753,108.4978279', 'uploads/1768876420_IMG-20251228-WA0029.jpg', 'Field trip ditanamam jagung madu pa warma dan Bu sarah bersama binannya mengenalkan jagung h72 dan ajak tanam dimt pertama diwilayah Cirebon, sekaligus order jagung madu 10 pcs, h72 4 pcs dan Lilac 10 pcs dan persiapan olah lahan untuk penanaman kembali', 2, '2026-01-20 09:39:46', 'approved', '2026-01-20 09:33:40', '2026-01-20 09:39:46', 5, 2),
(361, 8, 2, 7, '2026-01-20', 300000.00, 'Ds. Sumurugul Kec. Wanayasa Purwakarta', '', 'uploads/1768899928_IMG-20260109-WA0019.jpg', 'Farmer Meeting (FM)\r\nPengenalan all produk Advanta. Fokus Produk KCP Herra 22, Jagung Madu-59, Tomat Nona 23 F1, Cabai Rawit Shima, Cabai Keriting Agni dan Timun Lavanta bersama Mitra Petani Pak Asep.\r\nKecamatan Wanayasa, Purwakarta', 2, '2026-01-24 20:58:00', 'approved', '2026-01-20 16:05:29', '2026-01-24 20:58:00', 8, 2),
(362, 6, 2, 18, '2026-01-20', 300000.00, 'Ds. Padarek Kec. Kuningan Kab. Kuningan', '-6.9574901534778935,108.50863019863895', 'uploads/1768904077_293688F8-C3D2-4552-A84D-B14794F321DC.jpeg', '', 2, '2026-01-24 20:57:25', 'approved', '2026-01-20 17:14:37', '2026-01-24 20:57:25', 6, 2),
(363, 7, 2, 7, '2026-01-21', 300000.00, 'Sukamulyacisahang kertajati', '', 'uploads/1768968834_1000703314.jpg', 'Farmers Meeting ( FM )\r\nPengenalan produk advanta bersama mitra petani H.dodo petani palawija\r\nSold out 1iner lavanta \r\n2 pcs kp.herra\r\n🥒🫘🌶️\r\nDS.sukamulya Cisahang kec.kertajati', 2, '2026-01-24 20:57:57', 'approved', '2026-01-21 11:13:55', '2026-01-24 20:57:57', 7, 2),
(364, 8, 3, 8, '2026-01-21', 750000.00, 'Ds. Palasari Kec. Ciater Subang', '', 'uploads/1768982697_PhotoGrid_Plus_1768982564791.jpg', 'Study Banding / Field Trip (FT)\r\nMelihat Hasil Panen Tomat Nona 23 F1 dan pengenalan all produk Advanta. Fokus Produk Timun Lavanta, Jagung Madu-59, Tomat Nona 23 F1, Cabai Rawit Shima bersama Mitra Petani Pak Maman.\r\nKecamatan Ciater, Subang.', 2, '2026-01-24 20:57:47', 'approved', '2026-01-21 15:04:57', '2026-01-24 20:57:47', 8, 2),
(365, 6, 2, 13, '2026-01-21', 300000.00, 'Ds. Sunia kec. Banjaran kab. Majalengka', '-6.9572548,108.3477367', 'uploads/1768990196_IMG-20260121-WA0051.jpg', '', 2, '2026-01-24 20:57:31', 'approved', '2026-01-21 17:09:56', '2026-01-24 20:57:31', 6, 2),
(366, 8, 2, 8, '2026-01-22', 300000.00, 'Ds. Palasari Kec. Ciater Subang', '', 'uploads/1769072064_20260107_135427.jpg', 'Farmer Meeting (FM)\r\nPengenalan all produk Advanta. Fokus Produk Jagung Madu-59, Tomat Nona 23 F1, Cabai Rawit Shima dan Timun Lavanta bersama Mitra Petani Kang Didi.\r\nKecamatan Ciater, Subang.', 2, '2026-01-24 20:57:12', 'approved', '2026-01-22 15:54:25', '2026-01-24 20:57:12', 8, 2),
(367, 6, 2, 8, '2026-01-23', 300000.00, 'Ds. Cipulus kec. Cikijing kab. Majalengka', '', 'uploads/1769171150_IMG-20260123-WA0043.jpg', '', 2, '2026-01-24 20:57:06', 'approved', '2026-01-23 19:25:50', '2026-01-24 20:57:06', 6, 2),
(368, 5, 2, 18, '2026-01-23', 300000.00, 'Silihasih pabedilan', '-6.690151,108.4971574', 'uploads/1769246368_Picsart_26-01-23_14-13-51-026.jpg', 'Farmer mereeng bersmaama binaam pak darma dan pa saprudin mengenalkan benih h72 dan tanam jagung h72 14 bungkus melalui pak haji darga disilihasih cireebon', 2, '2026-01-24 20:56:58', 'approved', '2026-01-24 16:19:29', '2026-01-24 20:56:58', 5, 2),
(369, 5, 2, 18, '2026-01-21', 300000.00, 'Kaligawe, susukan, waled', '-6.690151,108.4971574', 'uploads/1769246556_IMG-20260121-WA0007.jpg', 'Farmer meteeng bersama binaan bandar pak haji darga dan pak haji ali wilayah kaligawe, dan kawal penanaman jagung h-72 dilahan mas arya 24 pcs Kaligawe, cirebon', 2, '2026-01-24 20:56:54', 'approved', '2026-01-24 16:22:37', '2026-01-24 20:56:54', 5, 2),
(370, 5, 8, NULL, '2026-01-25', 0.00, '', '-6.6942816,108.4966468', 'uploads/1769318580_IMG20260125100222.jpg', '', 2, '2026-01-27 11:18:16', 'approved', '2026-01-25 12:23:01', '2026-01-27 11:18:16', 5, 2),
(371, 8, 1, 13, '2026-01-23', 200000.00, 'Ciater, Subang', '', 'uploads/1769324247_PhotoGrid_Plus_1769324022026.jpg', 'Kios Bumi Hijau Makmur', 2, '2026-01-27 11:18:12', 'approved', '2026-01-25 13:57:27', '2026-01-27 11:18:12', 8, 2),
(372, 8, 3, 2, '2026-01-24', 750000.00, 'Ciater, Subang', '', 'uploads/1769324448_PhotoGrid_Plus_1769310497383.jpg', 'Study Banding / Field Trip (FT)\r\nMelihat Hasil Panen Jagung Manis Madu-59 F1 dan pengenalan all produk Advanta. Fokus Produk Timun Lavanta, Jagung Madu-59, Tomat Nona 23 F1 dan Cabai Rawit Shima bersama Mitra Petani Kang Alwi.\r\nKecamatan Ciater, Subang.', 2, '2026-01-27 11:18:08', 'approved', '2026-01-25 14:00:48', '2026-01-27 11:18:08', 8, 2),
(373, 7, 3, 7, '2026-01-24', 750000.00, 'Ligung', '', 'uploads/1769347274_1000666837.jpg', '', 2, '2026-01-27 11:18:03', 'approved', '2026-01-25 20:21:14', '2026-01-27 11:18:03', 7, 2),
(374, 7, 3, 1, '2026-01-25', 750000.00, 'Tarikolot palasah', '', 'uploads/1769347339_1000707631.jpg', '', 2, '2026-01-27 11:17:59', 'approved', '2026-01-25 20:22:19', '2026-01-27 11:17:59', 7, 2),
(375, 7, 2, 18, '2026-01-23', 300000.00, 'Kulur majalengka', '', 'uploads/1769347585_1000589450.jpg', 'Farmers Meeting\r\nPengenalan jagung manis H72 bersama mitra petani Okan putra\r\n🌽🌽🌽🌽\r\nKulur majalengka', 2, '2026-01-27 11:17:56', 'approved', '2026-01-25 20:26:25', '2026-01-27 11:17:57', 7, 2),
(376, 6, 3, 9, '2026-01-24', 750000.00, 'Ds. Argalingga Kec. Argapura Kab. Majalengka', '', 'uploads/1769387298_CDC43027-95B0-4C49-85D4-9A214DEC8A9B.jpeg', '', 2, '2026-01-27 11:17:53', 'approved', '2026-01-26 07:28:19', '2026-01-27 11:17:53', 6, 2),
(377, 6, 8, NULL, '2026-01-25', 0.00, '', '', NULL, '', 2, '2026-01-27 11:10:01', 'approved', '2026-01-26 07:29:01', '2026-01-27 11:10:01', 6, 2),
(378, 8, 2, 2, '2026-02-02', 300000.00, 'Ds. Neglasari Kec. Darangdan Purwakarta', '', 'uploads/1770016296_20260202_122021.jpg', 'Farmer Meeting (FM)\r\nPengenalan all produk Advanta. Fokus Produk Jagung Madu-59, Tomat Nona 23 F1, Cabai Rawit Shima dan Timun Lavanta bersama Mitra Petani Pak Ocang.\r\nKecamatan Darangdan, Purwakarta.', 2, '2026-02-13 11:26:43', 'approved', '2026-02-02 14:11:37', '2026-02-13 11:26:43', 8, 2),
(379, 8, 2, 2, '2026-02-09', 300000.00, 'Ds. Cikeris Kec. Bojong Purwakarta', '', 'uploads/1770619745_20260202_122309.jpg', 'Farmer Meeting (FM)\r\nPengenalan all produk Advanta. Fokus Produk Jagung Madu-59, Tomat Nona 23 F1, Cabai Rawit Shima dan Timun Lavanta bersama Mitra Petani Pak Asep.\r\nKecamatan Bojong, Purwakarta.', 2, '2026-02-13 11:26:37', 'approved', '2026-02-09 13:49:05', '2026-02-13 11:26:37', 8, 2),
(380, 7, 2, 6, '2026-02-06', 300000.00, 'Kasokandel', '', 'uploads/1770956938_1000707565.jpg', 'Farmer Meeting (FM)\r\nPengenalan all produk Advanta. Fokus Produk Timun Lavanta, Herra, Beijing\r\nBersama Mitra Petani bandar palawija Pak Cece & Aceng\r\nKasokandel kec kasokandel', 2, '2026-02-13 11:36:07', 'approved', '2026-02-13 11:28:58', '2026-02-13 11:36:07', 7, 2),
(381, 6, 3, 6, '2026-02-03', 1000000.00, 'Ds. Cihaur Kec. Maja Kab. Majalengka', '', 'uploads/1770956955_ABCA1EF6-A454-468D-B774-9505D2064998.jpeg', '', 2, '2026-02-13 11:35:57', 'approved', '2026-02-13 11:29:15', '2026-02-13 11:35:57', 6, 2),
(382, 7, 3, 10, '2026-02-09', 1000000.00, 'DS.banggala kec.kertajati', '', 'uploads/1770957031_1000723605.jpg', 'Field Trip (FT) melihat performa paria Beijing dan timun lavanta\r\nDilahan milik pak darma petikan ke4 bersama petani binaan bos Aep & mas Noto, \r\nSerta sharing mengenai respon pasar lokal dan induk, petani siap menanam di musim selanjutnya\r\n🥒🫘🍆🌶️\r\nBanggal', 2, '2026-02-13 11:35:44', 'approved', '2026-02-13 11:30:31', '2026-02-13 11:35:44', 7, 2),
(383, 6, 2, 8, '2026-02-10', 300000.00, 'Ds. Sagarahiang Kec. Darma Kab. Majalengka', '', 'uploads/1770957093_IMG_4285.jpeg', '', 2, '2026-02-13 11:35:27', 'approved', '2026-02-13 11:31:13', '2026-02-13 11:35:27', 6, 2),
(384, 5, 2, 18, '2026-02-12', 300000.00, 'Babakan pabuaran', '-6.702392,108.4676702', 'uploads/1770959882_Picsart_26-02-12_19-48-55-346.jpg', 'Farmer meteeng sekaligus kawal penanaman jagung h72 dilahan ke 2 pak darma 26 bungkus sekaligus menguatkan penyebaran jagung h72 dipetani sekitar dan ajak tanam kembali dipabuara babakan cirebon', 2, '2026-02-20 10:32:06', 'approved', '2026-02-13 12:18:02', '2026-02-20 10:32:06', 5, 2),
(385, 5, 2, 18, '2026-02-07', 300000.00, 'Pabedilan', '-6.7024199,108.4677129', 'uploads/1770959970_IMG-20260131-WA0014(2).jpg', 'Farmer meteeng bersama kelompok tani dan binaan bandar pa budin fokus produk jagung hibrix-72 dan ajak tanam sekaligus kawal penyebaran penanaman 1 dus hibrix 72 dicirebon', 2, '2026-02-20 10:32:01', 'approved', '2026-02-13 12:19:30', '2026-02-20 10:32:01', 5, 2),
(386, 5, 3, 1, '2026-02-10', 1000000.00, 'Ralun, Cirebon', '-6.7024199,108.4677129', 'uploads/1770960064_IMG-20260210-WA0034.jpg', 'Field trip bersama pak hendri dan binannya dari sumber ketalun dan binaan pak adi melihat performa jagung advanta lilac dan melihat hasil panenan jagung madu sekaligus kawal penanaman jagung madu dibinannya dicirebon. Sekaligus persiapan tanam kembali dan', 2, '2026-02-20 10:31:47', 'approved', '2026-02-13 12:21:05', '2026-02-20 10:31:47', 5, 2),
(387, 6, 2, 8, '2026-02-13', 300000.00, 'Ds. Lemahsugih Kec. Lemahsugih Kab. Majalengka', '', 'uploads/1770970365_IMG_4381.jpeg', '', 2, '2026-02-20 10:31:32', 'approved', '2026-02-13 15:12:45', '2026-02-20 10:31:32', 6, 2),
(388, 6, 3, 8, '2026-02-19', 1000000.00, 'Ds. Cisoka kec. Cikijing kab. Majalengka', '', 'uploads/1771483266_094000BF-1AD0-4E82-874B-FE30A85C0769.jpeg', '', 2, '2026-02-20 10:31:08', 'approved', '2026-02-19 13:41:06', '2026-02-20 10:31:08', 6, 2),
(389, 5, 2, 18, '2026-02-19', 300000.00, 'Pangenan cirebon', '-6.6928135,108.4975752', 'uploads/1771484542_Picsart_26-02-19_12-47-50-709.jpg', 'Farmer meteeng bersmaa binaan pak karmadi fokus benih jagung h72, lilac, madu, timun lavanta, paria beijing dan kcp herra. Sekaligus kawal penanaman jagung lilac 2 dus dan paria beijing 8 pcs di pangenan cirebon', 2, '2026-02-20 10:31:01', 'approved', '2026-02-19 14:02:23', '2026-02-20 10:31:01', 5, 2),
(390, 7, 2, 18, '2026-02-13', 300000.00, 'Jatiserang panyingkiran', '', 'uploads/1771563555_1000729626.jpg', 'FM silaturahmi dan pengenalan produk Advanta. Fokus Produk Jagung H72, Timun lavanta,KC.herra, paria Beijing, cabai rawit Shima\r\nBersama petani DS.jatiserang kec.panyingkiran Majalengka', 2, '2026-02-20 13:26:12', 'approved', '2026-02-20 11:59:15', '2026-02-20 13:26:12', 7, 2),
(391, 7, 2, 6, '2026-02-20', 300000.00, 'Cikamurang', '', 'uploads/1771563669_1000738646.jpg', 'Farmer Meeting (FM)\r\nPengenalan all produk Advanta. Timun Lavanta, KCP Herra 22, Beijing, Shima\r\nBersama mitra petani pak Dodo\r\nCikamurang Indramayu', 2, '2026-02-20 13:26:10', 'approved', '2026-02-20 12:01:09', '2026-02-20 13:26:10', 7, 2),
(392, 5, 2, 18, '2026-02-20', 300000.00, 'Ambit pabuaran', '-6.6928627,108.4973974', 'uploads/1771605862_Picsart_26-02-19_14-12-19-100.jpg', 'Pengganti odp dikios umi tani. Farmer meteeng bersama petani pak uka mengenalkan benih jagung h72, timun lavanta dan kcp herra diwilayah baru sekaligus ajak tanam kcp herra dan sebar sample timun lavanta, ambit pabuaran. Cirebon', 2, '2026-02-26 07:25:18', 'approved', '2026-02-20 23:44:22', '2026-02-26 07:25:18', 5, 2),
(393, 8, 2, 7, '2026-02-17', 300000.00, 'Ds. Legokhuni Kec. Wanayasa Purwakarta', '', 'uploads/1771823832_20260217_133610.jpg', 'Farmer Meeting (FM)\r\nPengenalan all produk Advanta. Fokus Produk Jagung Manis Madu-59, Tomat Nona 23 F1, Cabai Keriting Agni 22 F1 dan KCP Herra 22 bersama Mitra Petani Pak Asep.\r\nKecamatan Wanayasa, Purwakarta.', 2, '2026-02-26 07:25:12', 'approved', '2026-02-23 12:17:13', '2026-02-26 07:25:12', 8, 2),
(394, 8, 2, 2, '2026-02-23', 300000.00, 'Ds. Cileunca Kec. Darangdan purwakarta', '', 'uploads/1771830217_20260202_122213.jpg', 'Farmer Meeting (FM)\r\nPengenalan all produk Advanta. Fokus Produk Jagung Manis Madu-59, Tomat Nona 23 F1, Cabai Keriting Agni 22 F1 dan KCP Herra 22 bersama Mitra Petani Kang Rahmat.\r\nKec. Darangdan Purwakarta', 2, '2026-02-26 07:25:10', 'approved', '2026-02-23 14:03:37', '2026-02-26 07:25:10', 8, 2),
(395, 5, 2, 18, '2026-02-24', 300000.00, 'Waled pabuaran', '-6.899756,108.7115327', 'uploads/1771908679_Picsart_26-02-24_10-31-41-511.jpg', 'Farmer meteeng bersama binaan kios berkah mulya tani sekaligus pengenalan dan kawal penanaman jagung h72 diwaled pabuaran cirebon (pengganti odp karena stok kios sudah habis)', 2, '2026-02-26 07:25:07', 'approved', '2026-02-24 11:51:20', '2026-02-26 07:25:07', 5, 2),
(396, 7, 3, 6, '2026-02-24', 1000000.00, 'Cikamurang', '', 'uploads/1771945239_1000741696.jpg', 'FT timun lavanta di lahan bos dodo', 2, '2026-02-26 07:25:01', 'approved', '2026-02-24 22:00:39', '2026-02-26 07:25:01', 7, 2),
(397, 5, 8, NULL, '2026-02-25', 0.00, 'Plered', '-6.7045289,108.5037381', 'uploads/1771988958_IMG20260225100805.jpg', '', 2, '2026-02-26 07:24:58', 'approved', '2026-02-25 10:09:18', '2026-02-26 07:24:58', 5, 2),
(398, 6, 2, 6, '2026-02-25', 300000.00, 'Ds. Cikijing kec. Cikijing kab. Majalengka', '', 'uploads/1772026626_IMG_4679.jpeg', '', 2, '2026-02-26 07:24:55', 'approved', '2026-02-25 20:37:06', '2026-02-26 07:24:55', 6, 2),
(399, 6, 8, NULL, '2026-02-25', 0.00, '', '', NULL, '', 2, '2026-02-26 07:24:52', 'approved', '2026-02-25 20:37:22', '2026-02-26 07:24:52', 6, 2),
(400, 8, 1, 2, '2026-03-03', 200000.00, 'Ds. Nagrak Kec. Ciater Subang', '', 'uploads/1772504100_PhotoGrid_Plus_1772503863717.jpg', 'Kios Bumi Hijau Makmur', 2, '2026-03-09 09:36:40', 'approved', '2026-03-03 09:15:00', '2026-03-09 09:36:40', 8, 2);

-- --------------------------------------------------------

--
-- Table structure for table `activity_plans`
--

CREATE TABLE `activity_plans` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `date` date NOT NULL,
  `total_cost` decimal(10,2) NOT NULL DEFAULT 0.00,
  `notes` text DEFAULT NULL,
  `responded_by_id` bigint(20) UNSIGNED DEFAULT NULL,
  `responded_datetime` datetime DEFAULT NULL,
  `status` enum('approved','rejected','not_responded') NOT NULL DEFAULT 'not_responded',
  `created_datetime` datetime DEFAULT NULL,
  `updated_datetime` datetime DEFAULT NULL,
  `created_by_uid` bigint(20) UNSIGNED DEFAULT NULL,
  `updated_by_uid` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `activity_plans`
--

INSERT INTO `activity_plans` (`id`, `user_id`, `date`, `total_cost`, `notes`, `responded_by_id`, `responded_datetime`, `status`, `created_datetime`, `updated_datetime`, `created_by_uid`, `updated_by_uid`) VALUES
(4, 8, '2025-07-01', 2300000.00, NULL, 2, '2025-07-14 14:31:20', 'approved', '2025-07-14 10:01:59', '2025-07-14 14:31:20', 8, 2),
(5, 6, '2025-07-01', 2300000.00, NULL, 2, '2025-07-14 14:31:05', 'approved', '2025-07-14 10:03:51', '2025-07-14 14:31:05', 6, 2),
(6, 7, '2025-07-01', 6475000.00, NULL, 2, '2025-07-14 14:30:28', 'approved', '2025-07-14 11:07:58', '2025-07-14 14:30:28', 7, 2),
(7, 5, '2025-07-01', 6450000.00, 'Kegiatan bulan Juli 2025', 2, '2025-07-14 15:38:55', 'approved', '2025-07-14 13:24:07', '2025-07-14 15:38:55', 5, 2),
(8, 8, '2025-08-01', 6900000.00, NULL, 2, '2025-07-30 13:31:35', 'approved', '2025-07-21 17:44:12', '2025-07-30 13:31:35', 8, 2),
(9, 6, '2025-08-01', 6600000.00, NULL, 2, '2025-07-26 19:30:44', 'approved', '2025-07-21 19:55:43', '2025-07-26 19:30:44', 6, 2),
(10, 7, '2025-08-01', 2600000.00, NULL, 2, '2025-07-22 07:26:10', 'approved', '2025-07-21 20:17:32', '2025-07-22 07:26:10', 7, 2),
(11, 5, '2025-08-01', 2450000.00, NULL, 2, '2025-07-22 18:52:57', 'approved', '2025-07-21 21:21:30', '2025-07-22 18:52:57', 5, 2),
(12, 11, '2025-08-01', 0.00, 'Study Banding', NULL, NULL, 'not_responded', '2025-08-13 20:06:48', '2025-09-18 13:13:35', 11, 11),
(13, 11, '2025-09-01', 3000000.00, 'Farmer Field Day Di lahan pa ade jana varietas madu59', NULL, NULL, 'not_responded', '2025-08-13 20:15:37', '2025-09-02 06:51:15', 11, 11),
(14, 5, '2025-09-01', 2450000.00, NULL, 2, '2025-08-29 05:28:29', 'approved', '2025-08-21 09:58:37', '2025-08-29 05:28:29', 5, 2),
(15, 7, '2025-09-01', 2600000.00, NULL, 2, '2025-08-29 05:28:18', 'approved', '2025-08-27 13:11:55', '2025-08-29 05:28:18', 7, 2),
(16, 6, '2025-09-01', 2600000.00, NULL, 2, '2025-08-29 05:28:03', 'approved', '2025-08-28 09:55:45', '2025-08-29 05:28:03', 6, 2),
(17, 8, '2025-09-01', 2500000.00, 'FT 2\r\nFM 2\r\nODP 2', 2, '2025-08-29 05:27:43', 'approved', '2025-08-28 19:25:55', '2025-08-29 05:27:43', 8, 2),
(18, 19, '2025-09-01', 1400000.00, 'Rencana Kegiatan September 2025', 3, '2025-09-11 06:19:32', 'approved', '2025-08-31 09:41:12', '2025-09-11 06:19:32', 19, 3),
(19, 17, '2025-09-01', 1400000.00, 'Rencana Kegiatan September 2025', 3, '2025-09-11 06:19:28', 'approved', '2025-08-31 09:47:54', '2025-09-11 06:19:28', 17, 3),
(20, 18, '2025-09-01', 1400000.00, 'Rencana Kegiatan September 2025', 3, '2025-09-11 06:19:24', 'approved', '2025-08-31 09:48:32', '2025-09-11 06:19:24', 18, 3),
(21, 16, '2025-09-01', 4700000.00, 'Rencana Kegiatan September 2025', 3, '2025-09-11 06:19:20', 'approved', '2025-08-31 09:49:04', '2025-09-11 06:19:20', 16, 3),
(22, 15, '2025-09-01', 4800000.00, 'Rencana Kegiatan September 2025', 3, '2025-09-11 06:19:15', 'approved', '2025-08-31 09:49:37', '2025-09-11 06:19:15', 15, 3),
(23, 13, '2025-09-01', 1000000.00, NULL, 4, '2025-09-01 12:43:41', 'approved', '2025-09-01 12:20:55', '2025-09-01 12:43:41', 13, 4),
(31, 6, '2025-10-01', 3350000.00, NULL, 2, '2025-10-06 05:30:08', 'approved', '2025-10-01 07:32:02', '2025-10-06 05:30:08', 6, 2),
(32, 5, '2025-10-01', 2350000.00, NULL, 2, '2025-10-06 05:30:05', 'approved', '2025-10-01 18:46:50', '2025-10-06 05:30:05', 5, 2),
(33, 7, '2025-10-01', 2600000.00, NULL, 2, '2025-10-06 05:30:00', 'approved', '2025-10-01 20:50:50', '2025-10-06 05:30:00', 7, 2),
(34, 18, '2025-10-01', 0.00, 'ODPPUTERA BAROKAH CIKUBANG', NULL, NULL, 'not_responded', '2025-10-01 21:20:01', NULL, 18, NULL),
(35, 8, '2025-10-01', 2300000.00, NULL, 2, '2025-10-06 05:29:58', 'approved', '2025-10-02 12:21:58', '2025-10-06 05:29:58', 8, 2),
(36, 16, '2025-11-01', 0.00, 'Fm', NULL, NULL, 'not_responded', '2025-10-24 07:22:01', NULL, 16, NULL),
(37, 16, '2025-10-01', 0.00, 'Fm', NULL, NULL, 'not_responded', '2025-10-24 07:22:18', NULL, 16, NULL),
(38, 17, '2025-10-01', 6000000.00, 'Rencana Kegiatan Oktober 2025', NULL, NULL, 'not_responded', '2025-10-27 06:49:35', '2025-10-27 06:58:25', 17, 17),
(39, 7, '2025-11-01', 2700000.00, NULL, 2, '2025-10-31 08:39:06', 'approved', '2025-10-28 10:20:58', '2025-10-31 08:39:06', 7, 2),
(40, 8, '2025-11-01', 3600000.00, NULL, 2, '2025-10-31 08:38:07', 'approved', '2025-10-28 13:09:07', '2025-10-31 08:38:07', 8, 2),
(41, 5, '2025-11-01', 2700000.00, NULL, 2, '2025-10-31 08:37:09', 'approved', '2025-10-28 22:07:39', '2025-10-31 08:37:09', 5, 2),
(42, 6, '2025-11-01', 2700000.00, NULL, 2, '2025-10-31 08:34:50', 'approved', '2025-10-29 06:18:21', '2025-10-31 08:34:50', 6, 2),
(43, 6, '2025-12-01', 6700000.00, NULL, NULL, NULL, 'not_responded', '2025-11-19 07:18:40', '2025-11-19 07:37:02', 6, 6),
(44, 7, '2025-12-01', 6700000.00, NULL, NULL, NULL, 'not_responded', '2025-11-19 09:24:23', '2025-11-20 06:30:29', 7, 7),
(45, 8, '2025-12-01', 24200000.00, NULL, NULL, NULL, 'not_responded', '2025-11-19 09:38:42', '2025-11-27 13:28:00', 8, 8),
(46, 5, '2025-12-01', 3450000.00, NULL, NULL, NULL, 'not_responded', '2025-11-19 09:41:30', '2025-12-06 17:14:37', 5, 5),
(47, 6, '2026-01-01', 2700000.00, NULL, 2, '2026-01-15 19:38:47', 'approved', '2025-12-25 19:45:21', '2026-01-15 19:38:47', 6, 2),
(48, 8, '2026-01-01', 3450000.00, NULL, 2, '2025-12-25 20:29:17', 'approved', '2025-12-25 20:02:32', '2025-12-25 20:29:17', 8, 2),
(49, 5, '2026-01-01', 2700000.00, NULL, 2, '2026-01-15 19:38:44', 'approved', '2025-12-25 20:07:01', '2026-01-15 19:38:44', 5, 2),
(50, 7, '2026-01-01', 2700000.00, NULL, 2, '2026-01-15 19:38:42', 'approved', '2025-12-25 20:16:01', '2026-01-15 19:38:42', 7, 2),
(51, 6, '2026-02-01', 3200000.00, NULL, 2, '2026-01-27 12:41:52', 'approved', '2026-01-27 10:27:29', '2026-01-27 12:41:52', 6, 2),
(52, 7, '2026-02-01', 3200000.00, NULL, 2, '2026-01-27 12:16:28', 'approved', '2026-01-27 10:49:30', '2026-01-27 12:16:28', 7, 2),
(53, 8, '2026-02-01', 3700000.00, NULL, 2, '2026-01-27 12:16:58', 'approved', '2026-01-27 11:44:20', '2026-01-27 12:16:58', 8, 2),
(54, 5, '2026-02-01', 2500000.00, NULL, 2, '2026-01-27 12:42:14', 'approved', '2026-01-27 11:58:21', '2026-01-27 12:42:14', 5, 2),
(55, 6, '2026-03-01', 2200000.00, NULL, 2, '2026-02-26 13:41:56', 'approved', '2026-02-26 12:06:43', '2026-02-26 13:41:56', 6, 2),
(56, 7, '2026-03-01', 2900000.00, NULL, 2, '2026-02-26 13:42:02', 'approved', '2026-02-26 13:12:43', '2026-02-26 13:42:02', 7, 2),
(57, 5, '2026-03-01', 6200000.00, NULL, 2, '2026-02-26 13:51:27', 'approved', '2026-02-26 13:15:35', '2026-02-26 13:51:27', 5, 2),
(58, 8, '2026-03-01', 3100000.00, NULL, 2, '2026-02-26 15:14:55', 'approved', '2026-02-26 15:07:03', '2026-02-26 15:14:55', 8, 2);

-- --------------------------------------------------------

--
-- Table structure for table `activity_plan_details`
--

CREATE TABLE `activity_plan_details` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `parent_id` bigint(20) UNSIGNED NOT NULL,
  `type_id` bigint(20) UNSIGNED DEFAULT NULL,
  `product_id` bigint(20) UNSIGNED DEFAULT NULL,
  `date` date DEFAULT current_timestamp(),
  `cost` decimal(10,2) NOT NULL DEFAULT 0.00,
  `location` varchar(500) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_datetime` datetime DEFAULT NULL,
  `updated_datetime` datetime DEFAULT NULL,
  `created_by_uid` bigint(20) UNSIGNED DEFAULT NULL,
  `updated_by_uid` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `activity_plan_details`
--

INSERT INTO `activity_plan_details` (`id`, `parent_id`, `type_id`, `product_id`, `date`, `cost`, `location`, `notes`, `created_datetime`, `updated_datetime`, `created_by_uid`, `updated_by_uid`) VALUES
(9, 4, 1, 2, NULL, 200000.00, 'Tanjungsiang, Subang', 'Kios Tani Raharja (Pak H Iwan)', '2025-07-14 10:02:42', NULL, 8, NULL),
(10, 4, 1, 2, NULL, 200000.00, 'Tanjungsiang, Subang', 'Kios Barokah Tani (Bu Hj Aneng)', '2025-07-14 10:03:15', NULL, 8, NULL),
(11, 4, 2, 2, NULL, 200000.00, 'Ciater, Subang', NULL, '2025-07-14 10:05:28', NULL, 8, NULL),
(12, 5, 1, 8, NULL, 200000.00, 'Ds. Cipulus Kec. Cikijing Kab. Majalengka', 'Kios Mustika Mulya Tani', '2025-07-14 10:05:37', NULL, 6, NULL),
(13, 4, 2, 8, NULL, 200000.00, 'Ciater, Subang', NULL, '2025-07-14 10:05:48', NULL, 8, NULL),
(14, 4, 3, 6, NULL, 750000.00, 'Ciater, Subang', NULL, '2025-07-14 10:06:52', NULL, 8, NULL),
(15, 4, 3, 2, NULL, 750000.00, 'Ciater, Subang', NULL, '2025-07-14 10:07:16', NULL, 8, NULL),
(16, 5, 2, 6, NULL, 200000.00, 'Ds. Cikandang Kec. Luragung Kab. Kuningan', NULL, '2025-07-14 10:07:40', NULL, 6, NULL),
(17, 5, 3, 2, NULL, 750000.00, 'Ds. Cikandang Kec. Luragung Kab. Kuningan', NULL, '2025-07-14 10:09:32', NULL, 6, NULL),
(18, 5, 2, 8, NULL, 200000.00, 'Ds. Sukadana Kec. Argapura Kab. Majalengka', NULL, '2025-07-14 10:10:55', NULL, 6, NULL),
(19, 5, 2, 2, NULL, 200000.00, 'Ds. Sembawa Kec. Jalaksana Kab. Kuningan', NULL, '2025-07-14 10:14:52', NULL, 6, NULL),
(20, 5, 3, 5, NULL, 750000.00, 'Ds. Babakanmulya Kec. Jalaksana Kab. Kuninga', NULL, '2025-07-14 10:15:54', NULL, 6, NULL),
(21, 6, 2, 6, NULL, 200000.00, 'GadelIndramayu', NULL, '2025-07-14 11:08:52', NULL, 7, NULL),
(22, 6, 2, 2, NULL, 200000.00, 'Panyingkiran', NULL, '2025-07-14 11:10:25', NULL, 7, NULL),
(23, 6, 2, 2, NULL, 250000.00, 'Kertajati', NULL, '2025-07-14 11:10:52', NULL, 7, NULL),
(24, 6, 3, 10, NULL, 750000.00, 'Panyingkiran', NULL, '2025-07-14 11:11:20', NULL, 7, NULL),
(25, 6, 3, 1, NULL, 750000.00, 'Ligung', NULL, '2025-07-14 11:11:46', NULL, 7, NULL),
(26, 6, 4, 2, NULL, 4125000.00, 'Karang anyar dawuan', NULL, '2025-07-14 11:12:34', NULL, 7, NULL),
(27, 6, 1, 2, NULL, 200000.00, 'Kios cahayatani', NULL, '2025-07-14 11:13:14', NULL, 7, NULL),
(34, 7, 4, 2, NULL, 4000000.00, 'Talun,Cirebon', 'Ffd tanaman jagung manis madu dan lilac', '2025-07-14 14:32:55', NULL, 5, NULL),
(35, 7, 3, 2, NULL, 750000.00, 'Hulubanteng,Cirebon', NULL, '2025-07-14 14:38:44', NULL, 5, NULL),
(37, 7, 3, 2, NULL, 750000.00, 'Waled,Cirebon', NULL, '2025-07-14 14:39:44', NULL, 5, NULL),
(38, 7, 2, 2, NULL, 250000.00, 'Pabedila,Cirebon', NULL, '2025-07-14 14:40:15', NULL, 5, NULL),
(39, 7, 2, 4, NULL, 250000.00, 'Kalimukti,pabedilan', NULL, '2025-07-14 14:40:54', NULL, 5, NULL),
(40, 7, 1, 2, NULL, 200000.00, 'Sindanglaut (kios sumbertani)', NULL, '2025-07-14 14:41:37', NULL, 5, NULL),
(42, 7, 2, 2, NULL, 250000.00, 'GebangCirebon', NULL, '2025-07-14 14:44:43', NULL, 5, NULL),
(43, 7, 5, 2, NULL, 0.00, 'cirebon', NULL, '2025-07-17 08:49:53', NULL, 9, NULL),
(44, 7, 5, 2, NULL, 0.00, 'cirebon', NULL, '2025-07-17 08:50:05', NULL, 9, NULL),
(45, 7, 5, 2, NULL, 0.00, 'cirebon', NULL, '2025-07-17 08:50:16', NULL, 9, NULL),
(46, 7, 5, 2, NULL, 0.00, 'cirebon', NULL, '2025-07-17 08:50:33', NULL, 9, NULL),
(47, 7, 5, 2, NULL, 0.00, 'cirebon', NULL, '2025-07-17 08:50:47', NULL, 9, NULL),
(48, 8, 2, 8, NULL, 300000.00, 'Ciater, Subang', NULL, '2025-07-21 17:45:14', '2025-07-21 20:11:58', 8, 2),
(49, 8, 2, 8, NULL, 300000.00, 'Ciater, Subang', NULL, '2025-07-21 17:45:29', '2025-07-21 20:11:39', 8, 2),
(50, 8, 2, 8, NULL, 300000.00, 'Ciater, Subang', NULL, '2025-07-21 17:45:46', '2025-07-21 20:11:19', 8, 2),
(51, 8, 1, 8, NULL, 200000.00, 'Ciater, Subang', 'Kios Bumi Hijau Makmur', '2025-07-21 17:46:20', NULL, 8, NULL),
(52, 8, 3, 2, NULL, 750000.00, 'Darangdan, Purwakarta', NULL, '2025-07-21 17:46:38', NULL, 8, NULL),
(53, 8, 3, 8, NULL, 750000.00, 'Wanayasa, Purwakarta', NULL, '2025-07-21 17:46:56', NULL, 8, NULL),
(54, 8, 7, 2, NULL, 100000.00, 'Tanjungsiang, Subang', 'Kios Barokah Tani', '2025-07-21 17:47:26', NULL, 8, NULL),
(55, 8, 7, 2, NULL, 100000.00, 'Kalijati, Subang', 'Kios Tani Meysha', '2025-07-21 17:48:04', NULL, 8, NULL),
(56, 8, 7, 2, NULL, 100000.00, 'Plered, Purwakarta', 'Kios Rizky Tani', '2025-07-21 17:51:28', NULL, 8, NULL),
(57, 8, 5, 8, NULL, 0.00, 'Wanayasa, Purwakarta', 'Kios Fajar Tani Mandiri', '2025-07-21 17:52:57', '2025-07-21 18:58:53', 8, 2),
(58, 8, 5, 8, NULL, 0.00, 'Ciater, Subang', 'Kios Bumi Hijau Makmur', '2025-07-21 17:53:22', '2025-07-21 18:58:44', 8, 2),
(59, 8, 5, 8, NULL, 0.00, 'Ciater, Subang', 'Kios Subur Tani', '2025-07-21 17:54:13', '2025-07-21 18:58:36', 8, 2),
(60, 8, 5, 8, NULL, 0.00, 'Jalancagak, Subang', 'Kios KUD Rahayu', '2025-07-21 17:54:37', '2025-07-21 18:58:28', 8, 2),
(61, 8, 5, 8, NULL, 0.00, 'Tanjungsiang, Subang', 'Kios Tani Raharja', '2025-07-21 17:55:08', '2025-07-21 18:58:19', 8, 2),
(62, 9, 2, 2, NULL, 300000.00, 'Ds. Sembawa Kec. Jalaksana Kab. Kuningan', NULL, '2025-07-21 19:57:02', NULL, 6, NULL),
(63, 9, 2, 2, NULL, 300000.00, 'Ds. Sukamukti Kec. Jalaksana Kab. Kuningan', NULL, '2025-07-21 19:57:59', NULL, 6, NULL),
(64, 9, 2, 2, NULL, 300000.00, 'Ds. Sidamulya Kec. Jalaksana Kab. Kuningan', NULL, '2025-07-21 19:58:43', NULL, 6, NULL),
(65, 9, 1, 2, NULL, 200000.00, 'Kios Mandiri Jaya Tani', NULL, '2025-07-21 19:59:37', NULL, 6, NULL),
(66, 9, 4, 2, NULL, 4000000.00, 'Ds. Sukamukti Kec. Jalaksana Kab. Kuningan', NULL, '2025-07-21 20:00:19', '2025-07-26 19:03:50', 6, 6),
(67, 9, 3, 8, NULL, 750000.00, 'Ds. Sidamulya Kec. Jalaksana Kab. Kuningan', NULL, '2025-07-21 20:00:53', NULL, 6, NULL),
(68, 10, 2, 2, NULL, 300000.00, 'Panyingkiran', NULL, '2025-07-21 20:18:10', NULL, 7, NULL),
(69, 10, 2, NULL, NULL, 300000.00, 'Dawuan', NULL, '2025-07-21 20:19:05', NULL, 7, NULL),
(70, 10, 2, 6, NULL, 300000.00, 'Sukagumiwang', NULL, '2025-07-21 20:19:41', NULL, 7, NULL),
(71, 10, 3, 1, NULL, 750000.00, 'Sumberjaya', 'Parapatan dekat mitraplumbon', '2025-07-21 20:21:18', NULL, 7, NULL),
(72, 10, 3, 7, NULL, 750000.00, 'Kertajati', NULL, '2025-07-21 20:22:08', NULL, 7, NULL),
(73, 10, 1, 6, NULL, 200000.00, 'Sinartani', NULL, '2025-07-21 20:23:06', NULL, 7, NULL),
(74, 11, 1, 6, NULL, 200000.00, 'Kios diah lestari Sindanglaut', NULL, '2025-07-21 21:22:19', '2025-07-21 21:22:44', 5, 5),
(76, 11, 2, 4, NULL, 250000.00, 'Pabuaran', NULL, '2025-07-21 21:23:30', NULL, 5, NULL),
(78, 11, 2, 1, NULL, 250000.00, 'Perbatasan pabedilan losari', NULL, '2025-07-21 21:24:34', '2025-07-22 17:34:10', 5, 5),
(79, 11, 3, 2, NULL, 750000.00, 'Waled', NULL, '2025-07-21 21:25:06', NULL, 5, NULL),
(80, 11, 3, 2, NULL, 750000.00, 'Weru, cirebon', 'Opsi tanaman jagung madu dan jagung lilac pak likun', '2025-07-21 21:29:21', '2025-07-21 21:43:50', 5, 5),
(81, 11, 2, 2, NULL, 250000.00, 'Wanasaba dan serang cirebon', 'Planing dilahan binaan pak adi ada 2 opsi untuk acara fm dilahan melihat tanaman Lilac dan madu sekaligus penanamanjagung Revadan madu', '2025-07-21 21:43:17', '2025-07-22 17:33:46', 5, 5),
(82, 11, 7, 6, NULL, 0.00, 'Kios diah lestari', NULL, '2025-07-22 17:34:48', NULL, 5, NULL),
(83, 11, 7, 2, NULL, 0.00, 'Kios sumber tani sindang laut', NULL, '2025-07-22 17:35:19', NULL, 5, NULL),
(84, 11, 7, 2, NULL, 0.00, 'Kios Adi jaya Talun', NULL, '2025-07-22 17:36:05', NULL, 5, NULL),
(85, 11, 5, 1, NULL, 0.00, 'Kios suci Mulya tani pabedilan', NULL, '2025-07-22 17:37:57', NULL, 5, NULL),
(86, 11, 5, 2, NULL, 0.00, 'Kios sumber taniSindanglaut', NULL, '2025-07-22 17:39:10', NULL, 5, NULL),
(87, 11, 5, 1, NULL, 0.00, 'Kios diah lestari', NULL, '2025-07-22 17:39:36', NULL, 5, NULL),
(88, 11, 5, 1, NULL, 0.00, 'Kios tani makmur', NULL, '2025-07-22 17:40:18', NULL, 5, NULL),
(89, 11, 5, 1, NULL, 0.00, 'Kios umi tani sedawangi, cirebon', NULL, '2025-07-22 17:40:43', NULL, 5, NULL),
(90, 9, 3, 9, NULL, 750000.00, 'Ds. Argalingga Kec. Argapura Kab. Majalengka', NULL, '2025-07-26 19:06:21', NULL, 6, NULL),
(91, 8, 4, 2, NULL, 4000000.00, 'Bungursari, Purwakarta', NULL, '2025-07-30 13:30:43', NULL, 8, NULL),
(92, 14, 7, 2, NULL, 0.00, '', 'Branding kios Adijaya,Talun, cirebon', '2025-08-21 09:59:10', NULL, 5, NULL),
(93, 14, 7, 6, NULL, 0.00, 'Waled', 'Branding lavanta dikios berkahMulyatani waled', '2025-08-21 09:59:54', NULL, 5, NULL),
(94, 14, 7, 1, NULL, 0.00, 'Ciledug', 'Kios suci Mulyatani cirebon', '2025-08-21 10:00:32', NULL, 5, NULL),
(95, 14, 7, 6, NULL, 0.00, 'Sindanglaut', 'Branding Baner lavanta diKios sumber tani Cirebon', '2025-08-21 10:01:26', NULL, 5, NULL),
(96, 14, 7, 6, NULL, 0.00, 'Sindanglaut', 'Branding Baner diKios tani makmur', '2025-08-21 10:02:31', NULL, 5, NULL),
(97, 14, 3, 2, NULL, 750000.00, 'Talun', 'Kegiatan ft dilahan pak Adi fokus tanaman jagung madu dan kawal penanaman madu kembali', '2025-08-21 10:03:49', NULL, 5, NULL),
(98, 14, 3, 1, NULL, 750000.00, 'Pabedilan', 'Ft tanaman jagung Lilac sekaligus melihat performa jagung Reva dan sekaligus kawal penanaman serta kirim pesanan ulang', '2025-08-21 10:05:02', NULL, 5, NULL),
(99, 14, 2, 4, NULL, 250000.00, 'Jatirenggang', 'Farmer meteeng bersama petani binaan mas tatang kios berkah Mulya tani', '2025-08-21 10:06:01', NULL, 5, NULL),
(100, 14, 1, 2, NULL, 200000.00, 'Talun', 'Kios adi jaya minta suport kegiatan dikiosnya untuk mendobrak konsumen sekaligus persiapan untuk penanaman tahun baru', '2025-08-21 10:07:23', NULL, 5, NULL),
(101, 14, 2, 6, NULL, 250000.00, 'Sindanglaut', 'Koordinasi dengan kios sumber tani untuk diadakan FM sekaligus pantau lokasi penanmaanya', '2025-08-21 10:10:03', NULL, 5, NULL),
(102, 14, 2, 4, NULL, 250000.00, 'Gebang', NULL, '2025-08-21 10:12:45', NULL, 5, NULL),
(103, 15, 2, 6, NULL, 300000.00, 'Kasokandel', NULL, '2025-08-27 13:12:43', '2025-08-28 08:52:41', 7, 7),
(104, 15, 2, 6, NULL, 300000.00, 'Jatitujuh', NULL, '2025-08-27 13:13:16', '2025-08-28 08:52:32', 7, 7),
(105, 15, 2, 6, NULL, 300000.00, 'Kertajati', NULL, '2025-08-27 13:13:39', '2025-08-28 08:52:23', 7, 7),
(106, 15, 3, 10, NULL, 750000.00, 'Panyingkiran', NULL, '2025-08-27 13:14:48', NULL, 7, NULL),
(107, 15, 3, 6, NULL, 750000.00, 'Kertajati', NULL, '2025-08-27 13:15:10', NULL, 7, NULL),
(108, 15, 1, 2, NULL, 200000.00, 'Kios sobatani', NULL, '2025-08-27 13:15:35', NULL, 7, NULL),
(109, 16, 2, NULL, NULL, 300000.00, 'Jalaksana', NULL, '2025-08-28 09:56:17', NULL, 6, NULL),
(110, 16, 2, NULL, NULL, 300000.00, 'Sembawa', NULL, '2025-08-28 09:56:37', NULL, 6, NULL),
(111, 16, 2, NULL, NULL, 300000.00, 'Gandasoli', NULL, '2025-08-28 09:57:04', NULL, 6, NULL),
(112, 16, 1, NULL, NULL, 200000.00, 'Kios Mandiri Jaya Tani', NULL, '2025-08-28 09:57:36', NULL, 6, NULL),
(113, 16, 3, 8, NULL, 750000.00, 'Ds. Sukadana Kec. Argapura Kab. Majalengka', NULL, '2025-08-28 09:58:39', NULL, 6, NULL),
(114, 16, 3, 2, NULL, 750000.00, 'Ds. Sukamukti Kec. Jalaksana Kab. Kuningan', NULL, '2025-08-28 09:59:15', NULL, 6, NULL),
(115, 17, 3, 2, NULL, 750000.00, 'Ciater, Subang', 'Petani Kang Ujang', '2025-08-28 19:26:56', NULL, 8, NULL),
(116, 17, 3, 6, NULL, 750000.00, 'Ciater, Subang', 'Petani Pak Erwin', '2025-08-28 19:27:28', NULL, 8, NULL),
(117, 17, 2, 2, NULL, 300000.00, 'Serangpanjang, Subang', 'Petani Pak Encas', '2025-08-28 19:28:12', NULL, 8, NULL),
(118, 17, 1, 2, NULL, 200000.00, 'Tanjungsiang, Subang', 'Kios Barokah Tani', '2025-08-28 19:28:39', NULL, 8, NULL),
(119, 17, 1, 2, NULL, 200000.00, 'Tanjungsiang, Subang', 'Kios Tani Raharja', '2025-08-28 19:29:04', NULL, 8, NULL),
(120, 17, 2, 2, NULL, 300000.00, 'Purwakarta', NULL, '2025-08-28 19:35:51', NULL, 8, NULL),
(121, 18, 3, 6, NULL, 800000.00, 'Cikande', NULL, '2025-08-31 09:45:25', NULL, 19, NULL),
(122, 18, 1, NULL, NULL, 300000.00, 'Guna Tani', NULL, '2025-08-31 09:45:46', NULL, 19, NULL),
(123, 18, 1, NULL, NULL, 300000.00, 'Sinar Mulya', NULL, '2025-08-31 09:46:04', NULL, 19, NULL),
(125, 19, 3, 6, NULL, 800000.00, 'Singaparna', NULL, '2025-08-31 09:51:37', NULL, 3, NULL),
(126, 19, 1, NULL, NULL, 300000.00, 'Tumbuh Agro Subur', NULL, '2025-08-31 09:52:05', NULL, 3, NULL),
(127, 19, 1, 2, NULL, 300000.00, 'Rizky Tani', NULL, '2025-08-31 09:52:27', NULL, 3, NULL),
(128, 20, 3, 2, NULL, 800000.00, 'Tanjungsari', 'Mini FFD', '2025-08-31 09:53:07', NULL, 3, NULL),
(129, 20, 1, NULL, NULL, 300000.00, 'Subur Tani', NULL, '2025-08-31 09:53:31', NULL, 3, NULL),
(130, 20, 1, 2, NULL, 300000.00, 'Pusaka Tani', NULL, '2025-08-31 09:53:47', NULL, 3, NULL),
(131, 21, 4, 8, NULL, 3000000.00, 'Garut', NULL, '2025-08-31 09:54:29', '2025-08-31 09:54:46', 3, 3),
(132, 21, 3, 2, NULL, 800000.00, 'Garut', NULL, '2025-08-31 09:55:07', NULL, 3, NULL),
(133, 21, 1, NULL, NULL, 300000.00, 'Mitra Tani', NULL, '2025-08-31 09:55:25', NULL, 3, NULL),
(134, 21, 1, NULL, NULL, 300000.00, 'Citra Tani', NULL, '2025-08-31 09:55:38', NULL, 3, NULL),
(135, 21, 1, 6, NULL, 300000.00, 'Tani Makmur Putra', NULL, '2025-08-31 09:55:56', NULL, 3, NULL),
(136, 22, 4, 2, NULL, 4000000.00, 'Bandung', NULL, '2025-08-31 09:56:41', NULL, 3, NULL),
(137, 22, 3, 8, NULL, 800000.00, 'Arjasari', NULL, '2025-08-31 09:57:01', NULL, 3, NULL),
(138, 23, 2, 6, NULL, 250000.00, '', 'Sukabumi', '2025-09-01 12:21:17', NULL, 13, NULL),
(139, 23, 3, 13, NULL, 750000.00, 'Sukabumi', NULL, '2025-09-01 12:21:43', NULL, 13, NULL),
(140, 13, 4, 2, NULL, 3000000.00, '', 'Melihat perform madu59 dimana disana juga banyak penanam yang tidak sesuai dengan hasil bahkan keadaan daya berkecambah yang kurang baik, sedikit juga memperlihatkan pengurusan dan hasil dilahan pa jana yang sangat cukup Baik madu59 nya', '2025-09-02 06:51:15', NULL, 11, NULL),
(142, 31, 1, 2, '2025-10-03', 200000.00, 'Kios Sri Mulya Tani', NULL, '2025-10-01 07:33:15', NULL, 6, NULL),
(143, 31, 2, 2, '2025-10-10', 300000.00, 'Ds. Sukamukti Kec. Jalaksana Kab. Kuningan', NULL, '2025-10-01 07:35:06', NULL, 6, NULL),
(144, 31, 2, 2, '2025-10-17', 300000.00, 'Ds. Sidamulya Kec. Jalaksana Kab. Kuningan', NULL, '2025-10-01 07:36:12', NULL, 6, NULL),
(145, 31, 2, 2, '2025-10-24', 300000.00, 'Ds. Babakanmulya Kec. Jalaksana Kab. Kuningan', NULL, '2025-10-01 07:37:02', NULL, 6, NULL),
(146, 31, 3, 8, '2025-10-27', 750000.00, 'Ds. Sukadana Kec. Argapura Kab. Majalengka', NULL, '2025-10-01 07:41:27', '2025-10-01 07:49:38', 6, 6),
(147, 31, 3, 2, '2025-10-31', 750000.00, 'Ds. Sukamukti Kec. Jalaksana Kab. Kuningan', NULL, '2025-10-01 07:47:22', NULL, 6, NULL),
(148, 31, 3, 8, '2025-10-08', 750000.00, 'Ds. Sidaraja Kec. Cingambul Kab. Majalengka', NULL, '2025-10-01 10:21:58', NULL, 6, NULL),
(149, 32, 3, 1, '2025-10-03', 700000.00, 'WeruCirebon', 'Kegiatan field trip bersama binaan dan kelompok tani serta ppl wilayah Karangsari,batembat dan weru untuk kunjungan ke lahan pak likun melihat performa tanaman Lilac dan panen sekaligus tanam jagung madu 15 bungkus', '2025-10-01 18:52:55', NULL, 5, NULL),
(150, 32, 2, 2, '2025-10-06', 250000.00, 'Waled, cikulak', 'Mengenalkan dan menyebarkan produk h72,Reva ke petani dan para pocok untuk disebarkan kepetani lain diwilayahnya masing-masing mulai dari Pabuaran, jatirenggang, sumber, hulubanteng hingga keWaled', '2025-10-01 18:55:36', '2025-10-03 09:23:47', 5, 5),
(151, 32, 3, 2, '2025-10-08', 700000.00, 'Sawah gede,sumber,Cirebon', 'Fieldtrip, bersama binaan pak warma melihat performa jagung madu dan panen jagung madu ditempat persebaran petani kompetitor dan ajak untuk tanam jagung madu untuk persiapan tahun baru', '2025-10-01 18:59:44', NULL, 5, NULL),
(152, 32, 1, 2, '2025-10-14', 200000.00, 'Kios umi tani, sedawangi cirebon', 'Promo benih madu, lavanta diwilayah kios umi tani untuk persiapan tanam musim tahun baru', '2025-10-01 19:02:22', '2025-10-01 19:02:59', 5, 5),
(153, 32, 2, 1, '2025-10-17', 250000.00, 'Ciledug', 'Suport pengenalan kepetani binaan kios suci Mulyatani untuk mengenalkan dan mengeluarkan stok yang ada dikios suci Mulya tani', '2025-10-01 19:05:31', '2025-10-01 19:05:49', 5, 5),
(154, 32, 2, 4, '2025-10-21', 250000.00, 'Pabuaran', 'Memperkuat dan meyakinkan keberadaan jagung Reva dan h72 diwilayah pabuaran supaya bisa cepat tersebar', '2025-10-01 19:08:47', NULL, 5, NULL),
(155, 33, 2, 2, '2025-10-03', 300000.00, 'CijatiMajalengka', NULL, '2025-10-01 20:51:32', NULL, 7, NULL),
(156, 33, 2, 6, '2025-10-10', 300000.00, 'Kasokandel', NULL, '2025-10-01 20:52:23', NULL, 7, NULL),
(157, 33, 2, 6, '2025-10-17', 300000.00, 'kadipaten', NULL, '2025-10-01 20:53:03', NULL, 7, NULL),
(158, 33, 3, 1, '2025-10-06', 750000.00, 'Majasuka', NULL, '2025-10-01 20:55:01', '2025-10-03 08:57:10', 7, 7),
(159, 33, 3, 6, '2025-10-07', 750000.00, 'Maodin kertajati', NULL, '2025-10-01 20:55:43', NULL, 7, NULL),
(160, 33, 1, 6, '2025-10-15', 200000.00, 'Agrotani', NULL, '2025-10-01 20:56:39', '2025-10-03 09:01:52', 7, 7),
(161, 35, 3, 6, '2025-10-03', 750000.00, 'Ds. Nagrak Kec. Ciater Subang', NULL, '2025-10-02 12:23:36', NULL, 8, NULL),
(162, 35, 3, 6, '2025-10-06', 750000.00, 'Ds. Ponggang Kec. Serangpanjang Subang', NULL, '2025-10-02 12:25:09', NULL, 8, NULL),
(163, 35, 1, 2, '2025-10-07', 200000.00, 'Ds. Tanggulun Kec. Kalijati Subang', 'Kios Berkah Tani', '2025-10-02 12:26:40', NULL, 8, NULL),
(164, 35, 1, 2, '2025-10-08', 200000.00, 'Kec. Cikaum Subang', 'Kios Parvis Tani', '2025-10-02 12:27:28', NULL, 8, NULL),
(165, 35, 1, 2, '2025-10-09', 200000.00, 'Kec. Kalijati Subang', 'Kios Tani Meysha', '2025-10-02 12:28:15', NULL, 8, NULL),
(166, 35, 1, 2, '2025-10-10', 200000.00, 'Kec. Jalancagak Subang', 'Kios KUD Rahayu', '2025-10-02 12:31:14', NULL, 8, NULL),
(167, 38, 2, 6, '2025-10-27', 300000.00, 'Tarogong, Garut', NULL, '2025-10-27 06:52:40', '2025-10-27 06:53:42', 17, 17),
(168, 38, 2, 2, '2025-10-27', 300000.00, 'Curug Banyuresmi, Garut.', NULL, '2025-10-27 06:55:02', NULL, 17, NULL),
(169, 38, 1, 2, '2025-10-27', 300000.00, 'Kios Mitra Usaha Tani', NULL, '2025-10-27 06:55:34', NULL, 17, NULL),
(170, 38, 1, 2, '2025-10-27', 300000.00, 'Kios Tumbuh Agro Subur', NULL, '2025-10-27 06:55:56', NULL, 17, NULL),
(171, 38, 3, 6, '2025-10-27', 800000.00, 'Rancabango, Garut.', NULL, '2025-10-27 06:57:53', NULL, 17, NULL),
(172, 38, 4, 2, '2025-10-27', 4000000.00, 'Wanaraja, Garut.', NULL, '2025-10-27 06:58:25', NULL, 17, NULL),
(173, 39, 3, 6, '2025-11-03', 750000.00, 'DS.karang anayar kec.dawuan', NULL, '2025-10-28 10:22:54', NULL, 7, NULL),
(174, 39, 3, 1, '2025-11-12', 750000.00, 'Panyingkiran', NULL, '2025-10-28 10:28:45', '2025-10-30 07:23:35', 7, 7),
(175, 39, 2, 7, '2025-11-07', 300000.00, 'Block cangkuduDS.cipaku', NULL, '2025-10-28 10:29:39', NULL, 7, NULL),
(176, 39, 2, 7, '2025-11-14', 300000.00, 'SukamulyaKertajati', NULL, '2025-10-28 10:30:38', '2025-10-29 10:01:49', 7, 7),
(177, 39, 1, 7, '2025-11-10', 300000.00, 'Kios cahayatani', NULL, '2025-10-28 10:31:40', '2025-10-29 10:05:31', 7, 7),
(178, 39, 2, 7, '2025-11-21', 300000.00, 'Jatitujuh', NULL, '2025-10-28 10:32:46', '2025-10-29 10:02:49', 7, 7),
(179, 40, 3, 8, '2025-11-04', 750000.00, 'Ds. Nagrak Kec. Ciater Subang', 'Petani Kang Aji', '2025-10-28 13:10:02', NULL, 8, NULL),
(180, 40, 2, 2, '2025-11-11', 1500000.00, 'Ds. Gununghejo Kec. Darangdan Purwakarta', 'Big FM dengan Mitra Elevarm', '2025-10-28 13:11:43', NULL, 8, NULL),
(181, 40, 3, 8, '2025-11-13', 750000.00, 'Ds. Pusakamulya Kec. Kiarapedes Purwakarta', 'Petani Pak Hidayat', '2025-10-28 13:12:29', '2025-10-28 16:35:10', 8, 8),
(182, 40, 2, 8, '2025-11-20', 300000.00, 'Ds. Pasanggrahan Kec. Bojong Purwakarta', 'Petani Pak Endih', '2025-10-28 13:14:37', '2025-10-28 16:35:25', 8, 8),
(183, 40, 2, 8, '2025-11-24', 300000.00, 'Ds. Wanasari Kec. Wanayasa Purwakarta', 'Petani Pak H Omin', '2025-10-28 16:34:53', '2025-10-28 16:35:39', 8, 8),
(184, 41, 3, 1, '2025-11-02', 750000.00, 'Karangsari', NULL, '2025-10-28 22:08:44', '2025-10-31 08:36:49', 5, 2),
(185, 41, 3, 1, '2025-11-10', 750000.00, 'Weru', 'Pemanenan jagung madu dan lilac dilahan pak likun dan mas gandi', '2025-10-28 22:10:10', '2025-10-28 22:10:47', 5, 5),
(186, 41, 2, 2, '2025-11-05', 300000.00, 'Pamijahan, plumbon', 'Pengenalan wilayah baru sekaligus penanaman jagung madu dan Lilac', '2025-10-28 22:11:53', '2025-10-31 08:36:29', 5, 2),
(187, 41, 2, 4, '2025-11-01', 300000.00, 'Megu gede Cirebon', NULL, '2025-10-28 22:13:57', '2025-10-31 08:36:15', 5, 2),
(188, 41, 2, 4, '2025-11-19', 300000.00, 'Sumber, Pabuaran, Cirebon', 'Farmer meteeng dibinaan pak h.topik pengenalan benih Reva dan pengawalan penanaman jagung Lilac untuk binannya diwilayah sumber,Pabuaran, cirebon', '2025-10-28 22:16:43', '2025-10-31 08:35:52', 5, 2),
(189, 41, 1, 2, '2025-11-14', 300000.00, 'Sindanglaut', 'Odp dikios tani makmur penekanan promosi benih jagung madu,timun lavanta dan mengenalkan benih KCP herra', '2025-10-28 22:19:43', '2025-10-31 08:35:37', 5, 2),
(190, 42, 3, 2, '2025-11-07', 750000.00, 'Ds. Sukamukti Kec. Jalaksana Kab. Kuningnya', NULL, '2025-10-29 06:19:26', NULL, 6, NULL),
(191, 42, 3, 8, '2025-11-15', 750000.00, 'Ds. Tejamulya Kec. Argapura Kab. Majalengka', NULL, '2025-10-29 06:26:05', '2025-10-29 09:59:10', 6, 6),
(192, 42, 1, 2, '2025-11-06', 300000.00, 'Kios Mandiri Jaya Tani', NULL, '2025-10-29 06:27:20', '2025-10-30 06:39:20', 6, 6),
(193, 42, 2, 9, '2025-11-14', 300000.00, 'Ds. Cisantana Kec. Cigugur Kab. Kuningan', NULL, '2025-10-29 06:29:26', NULL, 6, NULL),
(194, 42, 2, 2, '2025-11-21', 300000.00, 'Ds. Peusing Kec. Jalaksana Kab. Kuningan', NULL, '2025-10-29 06:31:23', '2025-10-29 10:03:40', 6, 6),
(195, 42, 2, 2, '2025-11-25', 300000.00, 'Ds. Padarek Kec. Kuningan Kab. Kuningan', NULL, '2025-10-29 06:32:19', '2025-10-29 10:02:37', 6, 6),
(196, 43, 1, 8, '2025-12-01', 300000.00, 'Kios Mustika Mulya Tani', NULL, '2025-11-19 07:19:33', NULL, 6, NULL),
(197, 43, 2, 8, '2025-12-05', 300000.00, 'Ds. Cibunut Kec. Argapura Kab. Majalengka', NULL, '2025-11-19 07:21:07', NULL, 6, NULL),
(198, 43, 2, 9, '2025-12-12', 300000.00, 'Ds. Argamukti Kec. Argapura Kab. Majalengka', NULL, '2025-11-19 07:26:19', '2025-11-19 07:37:42', 6, 6),
(199, 43, 2, 6, '2025-12-19', 300000.00, 'Ds. Kalapa Gunung Kec. Kramatmulya Kab. Kuningan', NULL, '2025-11-19 07:29:50', NULL, 6, NULL),
(200, 43, 3, 8, '2025-12-24', 750000.00, 'Ds. Sunia Kec. Banjaran Kab. Majalengka', NULL, '2025-11-19 07:31:18', NULL, 6, NULL),
(201, 43, 3, 7, '2025-12-23', 750000.00, 'Ds. Jalaksana Kec. Jalaksana Kab. Kuningan', NULL, '2025-11-19 07:35:07', NULL, 6, NULL),
(202, 43, 4, 8, '2025-12-22', 4000000.00, 'Ds. Cipulus kec. Cikijing kab. Majalengka', NULL, '2025-11-19 07:37:02', NULL, 6, NULL),
(203, 44, 2, 2, '2025-12-01', 300000.00, 'Lewimunding', NULL, '2025-11-19 09:38:42', '2025-11-21 05:02:17', 7, 7),
(204, 45, 3, 6, '2025-12-11', 750000.00, 'Ds. Nagrak Kec. Ciater Subang', 'Petani Kang Aji', '2025-11-19 09:39:31', '2025-11-19 09:40:56', 8, 8),
(205, 44, 2, 1, '2025-12-06', 300000.00, 'Kadipaten', NULL, '2025-11-19 09:40:02', '2025-11-21 12:26:56', 7, 7),
(206, 44, 2, 7, '2025-12-19', 300000.00, 'Sukagumiwang', NULL, '2025-11-19 09:40:36', NULL, 7, NULL),
(207, 45, 3, 8, '2025-12-04', 750000.00, 'Ds. Palasari Kec. Ciater Subang', 'Petani Kang Sandi', '2025-11-19 09:40:44', NULL, 8, NULL),
(208, 45, 4, 2, '2025-12-27', 20000000.00, 'Ds. Cibungur Kec. Bungursari Purwakarta', 'Petani Pak Asnu', '2025-11-19 09:41:46', '2025-11-28 16:26:44', 8, 8),
(209, 45, 2, 6, '2025-12-05', 300000.00, 'Ds. Cisaat Kec. Ciater Subang', 'Pak Yana', '2025-11-19 09:43:09', NULL, 8, NULL),
(210, 45, 2, 2, '2025-12-12', 300000.00, 'Ds. Bunihayu Kec. Jalancagak Subang', 'Petani Pak Abo', '2025-11-19 09:45:03', NULL, 8, NULL),
(211, 45, 2, 8, '2025-12-19', 300000.00, 'Kec. Bojong Purwakarta', NULL, '2025-11-19 09:45:39', NULL, 8, NULL),
(212, 46, 4, 2, '2025-12-17', 1500000.00, 'Waled lahan mas Erwan (Big FT)', 'Yang disini ada 2 tempat tanaman yang pertama 50 hst dan yang satunya umur 40 hst an. Ada opsi ffd ditempat lain seperti pak Nana ada jg Reva, madu dan eksotik umur 58, mas Erwan madu 42 hst dan Irman reva 34 hst.\n\nMenunggu dicek mas Agis mana yang sesuai', '2025-11-19 09:46:09', '2025-12-06 17:14:37', 5, 5),
(213, 45, 2, 6, '2025-12-16', 300000.00, 'Ds. Legokhuni Kec. Wanayasa Purwakarta', 'Petani Kang Iwan', '2025-11-19 09:46:55', NULL, 8, NULL),
(215, 44, 1, 7, '2025-12-03', 300000.00, 'Kios sobatani', NULL, '2025-11-19 09:53:32', NULL, 7, NULL),
(216, 44, 3, 7, '2025-12-18', 750000.00, 'Ligung', 'Di lahan h.abay', '2025-11-19 09:55:08', '2025-11-25 07:28:23', 7, 7),
(217, 46, 3, 4, '2025-12-02', 750000.00, 'Jati renggang', 'Untuk tanaman ada reva, madu dan kompetitor', '2025-11-19 09:56:21', '2025-11-28 10:17:48', 5, 5),
(218, 46, 2, 4, '2025-12-08', 300000.00, 'Jatirenggang', NULL, '2025-11-19 09:57:27', '2025-12-06 17:12:31', 5, 5),
(219, 46, 1, 7, '2025-12-01', 300000.00, 'Kios Sumbertani sindanglaut', 'Bantu reduksi sekaligus promo untuk mengurangi stok yang baru diturunkan', '2025-11-19 10:00:22', '2025-11-28 10:13:31', 5, 5),
(220, 44, 3, 7, '2025-12-16', 750000.00, 'Girimukti kasokandel', NULL, '2025-11-19 10:01:01', '2025-11-26 15:45:32', 7, 7),
(221, 46, 2, 4, '2025-12-19', 300000.00, 'Hulubanteng', 'Mengenalkan jagung reva dan h72', '2025-11-19 10:02:04', '2025-11-19 10:17:44', 5, 5),
(222, 46, 2, 4, '2025-12-22', 300000.00, 'Gebang', 'Mengenalkan reva dan sekaligus mengenalkan jagung h72', '2025-11-19 10:05:46', NULL, 5, NULL),
(223, 44, 4, 7, '2025-12-20', 4000000.00, 'Sukakerta kertajati', NULL, '2025-11-20 06:30:29', '2025-11-25 07:28:49', 7, 7),
(224, 45, 3, 6, '2025-12-02', 750000.00, 'Ds. Ciater Kec. Ciater Subang', 'Petani Pak Eneb', '2025-11-27 13:24:57', NULL, 8, NULL),
(225, 45, 3, 2, '2025-12-20', 750000.00, 'Ds. Ciater Kec. Ciater Subang', 'Petani Kang Ujang', '2025-11-27 13:28:00', NULL, 8, NULL),
(226, 47, 2, 13, '2026-01-09', 300000.00, 'Ds. Sunia Kec. Banjaran Kec. Majalengka', NULL, '2025-12-25 19:46:46', NULL, 6, NULL),
(227, 47, 2, 13, '2026-01-16', 300000.00, 'Ds. Sangiang Kec. Banjaran Kab. Majalengka', NULL, '2025-12-25 19:48:42', '2025-12-25 19:49:04', 6, 6),
(228, 47, 2, 13, '2026-01-23', 300000.00, 'Ds. Lemahsugih Kec. Lemahsugih Kab. Majalengka', NULL, '2025-12-25 19:49:46', NULL, 6, NULL),
(229, 47, 2, 13, '2026-01-19', 300000.00, 'Ds. Gunung Manik Kec. Talaga Kab. Majalengka', NULL, '2025-12-25 19:51:24', NULL, 6, NULL),
(230, 47, 3, 8, '2026-01-15', 750000.00, 'Ds. Sunia Kec. Banjaran Kab. Majalengka', NULL, '2025-12-25 19:54:37', NULL, 6, NULL),
(231, 47, 3, 8, '2026-01-22', 750000.00, 'Ds. Lemahsugih Kec. Lemahsugih Kab. Majalengka', NULL, '2025-12-25 19:56:25', NULL, 6, NULL),
(232, 48, 3, 8, '2026-01-05', 750000.00, 'Ds. Palasari Kec. Ciater Subang', 'Petani Pak Maman', '2025-12-25 20:11:29', NULL, 8, NULL),
(233, 49, 2, 18, '2026-01-05', 300000.00, 'Pabedilan', NULL, '2025-12-25 20:11:30', '2025-12-25 20:11:42', 5, 5),
(234, 48, 3, 11, '2026-01-09', 750000.00, 'Ds. Palasari Kec. Ciater Subang', 'Petani Pak Idin', '2025-12-25 20:12:09', NULL, 8, NULL),
(235, 49, 2, 18, '2026-01-13', 300000.00, 'Pabedilan', NULL, '2025-12-25 20:12:10', NULL, 5, NULL),
(236, 49, 2, 18, '2026-01-09', 300000.00, 'Pabuaran', NULL, '2025-12-25 20:13:16', NULL, 5, NULL),
(237, 48, 3, 2, '2026-01-12', 750000.00, 'Ds. Palasari Kec. Ciater Subang', 'Petani Kang Andri', '2025-12-25 20:14:35', NULL, 8, NULL),
(238, 49, 2, 18, '2026-01-20', 300000.00, 'Pabuaran', NULL, '2025-12-25 20:15:17', '2025-12-25 20:33:50', 5, 5),
(239, 48, 2, 8, '2026-01-16', 300000.00, 'Kec. Ciater Subang', NULL, '2025-12-25 20:17:16', NULL, 8, NULL),
(240, 50, 2, 18, '2026-01-09', 300000.00, 'Bonang', NULL, '2025-12-25 20:17:28', NULL, 7, NULL),
(241, 48, 2, 6, '2026-01-19', 300000.00, 'Kec. Bojong Purwakarta', NULL, '2025-12-25 20:18:06', NULL, 8, NULL),
(242, 50, 2, 7, '2026-01-20', 300000.00, 'Sukamulya / CisahangKertajati', NULL, '2025-12-25 20:19:12', '2025-12-25 22:42:08', 7, 7),
(243, 48, 2, 7, '2026-01-21', 300000.00, 'Kec. Wanayasa Purwakarta', NULL, '2025-12-25 20:21:26', '2025-12-25 20:24:48', 8, 8),
(244, 48, 2, 8, '2026-01-23', 300000.00, 'Kec. Bojong Purwakarta', NULL, '2025-12-25 20:23:39', '2025-12-25 20:24:21', 8, 8),
(245, 49, 3, 2, '2026-01-01', 750000.00, 'Sawah gede sumber', NULL, '2025-12-25 20:31:25', '2025-12-25 20:31:53', 5, 5),
(246, 49, 3, 2, '2026-01-02', 750000.00, 'Waled', NULL, '2025-12-25 20:33:03', '2025-12-25 22:28:40', 5, 5),
(247, 50, 3, 10, '2026-01-24', 750000.00, 'BanggalaKertajati', NULL, '2025-12-25 20:34:36', NULL, 7, NULL),
(248, 50, 2, 18, '2026-01-16', 300000.00, 'Cijurey', NULL, '2025-12-25 20:37:46', NULL, 7, NULL),
(249, 50, 2, 18, '2026-01-23', 300000.00, 'Kulur', NULL, '2025-12-25 20:42:55', '2025-12-25 22:41:35', 7, 7),
(250, 50, 3, 1, '2025-12-25', 750000.00, 'Tarikolot', NULL, '2025-12-25 20:44:43', NULL, 7, NULL),
(251, 51, 3, 6, '2026-02-02', 1000000.00, 'Ds. Cihaur Kec. Maja kab. Majalengka', NULL, '2026-01-27 10:29:43', '2026-01-27 12:17:33', 6, 6),
(252, 51, 3, 8, '2026-02-25', 1000000.00, 'Ds. Cisoka Kec. Cikijing Kab. Majalengka', NULL, '2026-01-27 10:32:26', '2026-01-27 12:17:09', 6, 6),
(253, 51, 2, 13, '2026-02-09', 300000.00, 'Ds. Gunungmanik Kec. Talaga Kab. Majalengka', NULL, '2026-01-27 10:34:57', '2026-01-27 12:13:45', 6, 2),
(254, 51, 2, 13, '2026-02-13', 300000.00, 'Ds. Lemahsugih Kec. Lemahsugih Kab. Majalengka', NULL, '2026-01-27 10:36:05', NULL, 6, NULL),
(255, 51, 2, 8, '2026-02-20', 300000.00, 'Ds. Sagarahiang Kec. Darma Kab. Kuningan', NULL, '2026-01-27 10:38:49', NULL, 6, NULL),
(256, 51, 2, 8, '2026-02-06', 300000.00, 'Pendetan , ds sangiang majalengka', NULL, '2026-01-27 10:40:00', '2026-01-27 12:13:23', 6, 2),
(257, 52, 2, 6, '2026-02-06', 300000.00, 'Kasokandel', NULL, '2026-01-27 10:50:22', NULL, 7, NULL),
(258, 52, 2, 18, '2026-02-13', 300000.00, 'Jatiserang', NULL, '2026-01-27 10:51:39', NULL, 7, NULL),
(259, 52, 2, 7, '2026-02-20', 300000.00, 'Cikamurang', NULL, '2026-01-27 10:52:19', NULL, 7, NULL),
(260, 52, 3, 10, '2026-02-09', 1000000.00, 'BanggalaKertajati', NULL, '2026-01-27 10:53:15', '2026-01-27 12:16:15', 7, 2),
(261, 52, 3, 6, '2026-02-24', 1000000.00, 'Cibuluh cikamurang', NULL, '2026-01-27 10:55:37', '2026-01-27 12:16:05', 7, 2),
(262, 52, 2, 7, '2026-02-11', 300000.00, 'cibogor ,ligung, beber', NULL, '2026-01-27 10:56:44', '2026-01-27 12:15:05', 7, 2),
(263, 53, 2, 2, '2026-02-06', 300000.00, 'Ds. Pameungpeuk Kec. Wanayasa Purwakarta', NULL, '2026-01-27 11:45:23', NULL, 8, NULL),
(264, 53, 2, 2, '2026-02-13', 300000.00, 'Ds. Cikeris Kec. Bojong Purwakarta', NULL, '2026-01-27 11:46:13', NULL, 8, NULL),
(265, 53, 2, 2, '2026-02-14', 300000.00, 'Ds. Cilingga Kec. Darangdan Purwakarta', NULL, '2026-01-27 11:51:16', '2026-01-27 11:59:07', 8, 8),
(266, 53, 2, 2, '2026-02-10', 300000.00, 'Ds. Selaawi Kec. Pasawahan Purwakarta', NULL, '2026-01-27 11:54:20', NULL, 8, NULL),
(269, 53, 3, 11, '2026-02-19', 1000000.00, 'Ds. Palasari Kec. Ciater Subang', NULL, '2026-01-27 11:57:05', NULL, 8, NULL),
(270, 54, 3, 1, '2026-01-03', 1000000.00, 'Sarwadadi', 'Ft dilahan pak adi', '2026-01-27 11:59:01', NULL, 5, NULL),
(271, 54, 2, 18, '2026-01-07', 300000.00, 'Pabedilan', NULL, '2026-01-27 11:59:27', NULL, 5, NULL),
(272, 54, 2, 18, '2026-01-09', 300000.00, 'Pabuaran lor', NULL, '2026-01-27 11:59:53', NULL, 5, NULL),
(273, 54, 1, 18, '2026-01-22', 300000.00, 'Berkah mulya tani', NULL, '2026-01-27 12:00:38', NULL, 5, NULL),
(274, 53, 3, 8, '2026-02-16', 1500000.00, 'Ds. Palasari Kec. Ciater Subang', NULL, '2026-01-27 12:00:48', NULL, 8, NULL),
(275, 54, 1, 2, '2026-01-19', 300000.00, 'Kios umi tani', NULL, '2026-01-27 12:01:45', NULL, 5, NULL),
(276, 54, 2, 18, '2026-01-27', 300000.00, 'Pasaleman waled', NULL, '2026-01-27 12:02:27', NULL, 5, NULL),
(277, 55, 2, 8, '2026-03-02', 300000.00, 'Ds. Karanganyar Kec. Darma Kab. Kuningan', NULL, '2026-02-26 12:07:41', NULL, 6, NULL),
(278, 55, 1, 8, '2026-03-03', 300000.00, 'Kios Mustika Mulya Tani', NULL, '2026-02-26 12:09:01', NULL, 6, NULL),
(279, 55, 1, 6, '2026-02-06', 300000.00, 'Kios Rahayu Tani', NULL, '2026-02-26 12:12:05', '2026-02-26 12:14:44', 6, 6),
(280, 55, 1, 2, '2026-03-09', 300000.00, 'Kios Mandiri Jaya Tani', NULL, '2026-02-26 12:13:58', NULL, 6, NULL),
(281, 55, 3, 5, '2026-03-13', 1000000.00, 'Ds. Babakanmulya Kec. Jalaksana Kab. Kuningan', NULL, '2026-02-26 12:17:27', NULL, 6, NULL),
(282, 57, 4, 18, '2026-03-10', 4000000.00, 'Hulubanteng', 'Kegiatan big fm sekaligus buka puasa bersama dan mengenalkan jagung h72 diwilayah hulubanteng dan sekitarnya', '2026-02-26 13:17:11', '2026-02-26 16:27:20', 5, 2),
(283, 56, 3, 7, '2026-02-02', 1000000.00, 'Mekarjaya', 'MekarjayaKertajati lahan pak ujang', '2026-02-26 13:17:25', NULL, 7, NULL),
(284, 57, 2, 18, '2026-03-02', 300000.00, 'Susukan kaligawe cirebon', 'Fm diwlayah susukan dan kaligawe bersama binaan pa haji ali', '2026-02-26 13:19:03', NULL, 5, NULL),
(285, 56, 1, 6, '2026-02-03', 300000.00, 'Cahayatani', NULL, '2026-02-26 13:19:49', NULL, 7, NULL),
(286, 56, 1, 6, '2026-02-06', 300000.00, 'Kios sobatani', NULL, '2026-02-26 13:20:31', NULL, 7, NULL),
(287, 57, 2, 18, '2026-02-05', 300000.00, 'Pabuaran sumber', NULL, '2026-02-26 13:22:03', NULL, 5, NULL),
(288, 57, 2, 18, '2026-02-16', 300000.00, 'Ciledug, cirebon', NULL, '2026-02-26 13:22:50', '2026-02-26 13:25:43', 5, 5),
(289, 56, 2, 18, '2026-03-13', 300000.00, 'Leuwiseeng', NULL, '2026-02-26 13:23:40', NULL, 7, NULL),
(290, 56, 3, 6, '2026-03-16', 1000000.00, 'Ligung', 'Di lahan pak imeyyy', '2026-02-26 13:24:39', NULL, 7, NULL),
(291, 57, 3, 18, '2026-03-11', 1000000.00, 'Cikulak waled', NULL, '2026-02-26 13:25:26', NULL, 5, NULL),
(292, 57, 1, 18, '2026-02-17', 300000.00, 'Kios berkah mulya tani', NULL, '2026-02-26 13:35:09', '2026-02-26 13:35:34', 5, 5),
(294, 58, 1, 8, '2026-03-02', 200000.00, 'Ciater, Subang', 'Kios Bumi Hijau Makmur', '2026-02-26 15:07:56', NULL, 8, NULL),
(295, 58, 2, 2, '2026-03-12', 300000.00, 'Bojong Barat Kec. Bojong Purwakarta', NULL, '2026-02-26 15:09:13', NULL, 8, NULL),
(296, 58, 2, 2, '2026-03-14', 300000.00, 'Cibingbin Kec. Bojong Purwakarta', NULL, '2026-02-26 15:10:12', NULL, 8, NULL),
(297, 58, 2, 2, '2026-03-13', 300000.00, 'Bojong Timur Kec. Bojong Purwakarta', NULL, '2026-02-26 15:11:00', NULL, 8, NULL),
(298, 58, 3, 9, '2026-02-16', 1000000.00, 'Ds. Nagrak Kec. Ciater Subang', 'Petani Kang Aji', '2026-02-26 15:12:03', NULL, 8, NULL),
(299, 58, 3, 2, '2026-02-17', 1000000.00, 'Ds. Palasari Kec. Ciater Subang', 'Petani Pak Jeje', '2026-02-26 15:12:39', NULL, 8, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `activity_targets`
--

CREATE TABLE `activity_targets` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `year` smallint(5) UNSIGNED NOT NULL,
  `quarter` tinyint(3) UNSIGNED DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_datetime` datetime DEFAULT NULL,
  `updated_datetime` datetime DEFAULT NULL,
  `created_by_uid` bigint(20) UNSIGNED DEFAULT NULL,
  `updated_by_uid` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `activity_targets`
--

INSERT INTO `activity_targets` (`id`, `user_id`, `year`, `quarter`, `notes`, `created_datetime`, `updated_datetime`, `created_by_uid`, `updated_by_uid`) VALUES
(12, 5, 2025, 2, NULL, '2025-07-14 13:12:20', NULL, 9, NULL),
(13, 6, 2025, 2, NULL, '2025-07-14 13:12:38', NULL, 9, NULL),
(14, 7, 2025, 2, NULL, '2025-07-14 13:13:57', NULL, 9, NULL),
(15, 8, 2025, 2, NULL, '2025-07-14 13:14:05', NULL, 9, NULL),
(16, 14, 2025, 2, NULL, '2025-09-01 12:25:47', NULL, 4, NULL),
(17, 13, 2025, 2, NULL, '2025-09-01 12:26:33', '2025-09-01 12:46:36', 4, 4),
(18, 5, 2025, 3, NULL, '2025-10-01 15:28:14', NULL, 2, NULL),
(19, 6, 2025, 3, NULL, '2025-10-01 15:30:17', NULL, 2, NULL),
(20, 7, 2025, 3, NULL, '2025-10-01 15:30:26', NULL, 2, NULL),
(21, 8, 2025, 1, NULL, '2025-10-01 15:30:33', NULL, 2, NULL),
(22, 8, 2025, 3, NULL, '2025-10-02 05:32:52', NULL, 2, NULL),
(23, 5, 2026, 4, NULL, '2026-01-27 11:22:49', NULL, 2, NULL),
(24, 6, 2026, 1, NULL, '2026-01-27 11:23:07', NULL, 2, NULL),
(25, 7, 2026, 1, NULL, '2026-01-27 11:23:19', NULL, 2, NULL),
(26, 8, 2026, 1, NULL, '2026-01-27 11:23:30', NULL, 2, NULL),
(27, 5, 2025, 4, NULL, '2026-01-27 11:32:16', NULL, 2, NULL),
(28, 6, 2025, 4, NULL, '2026-01-27 11:32:48', NULL, 2, NULL),
(29, 7, 2025, 4, NULL, '2026-01-27 11:33:07', NULL, 2, NULL),
(30, 8, 2025, 4, NULL, '2026-01-27 11:33:21', NULL, 2, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `activity_target_details`
--

CREATE TABLE `activity_target_details` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `parent_id` bigint(20) UNSIGNED NOT NULL,
  `type_id` bigint(20) UNSIGNED NOT NULL,
  `quarter_qty` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `month1_qty` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `month2_qty` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `month3_qty` tinyint(3) UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `activity_target_details`
--

INSERT INTO `activity_target_details` (`id`, `parent_id`, `type_id`, `quarter_qty`, `month1_qty`, `month2_qty`, `month3_qty`) VALUES
(1, 1, 1, 3, 1, 1, 1),
(2, 1, 2, 9, 3, 3, 3),
(3, 1, 3, 3, 1, 1, 1),
(4, 1, 4, 1, 0, 0, 1),
(5, 4, 1, 3, 1, 1, 1),
(6, 4, 2, 9, 3, 3, 3),
(7, 4, 3, 3, 1, 1, 1),
(8, 4, 4, 1, 0, 0, 1),
(11, 6, 1, 3, 1, 1, 1),
(12, 6, 2, 9, 3, 3, 3),
(13, 6, 3, 3, 1, 1, 1),
(14, 6, 4, 1, 0, 0, 1),
(15, 7, 1, 3, 1, 1, 1),
(16, 7, 2, 9, 3, 3, 3),
(17, 7, 3, 3, 1, 1, 1),
(18, 7, 4, 1, 0, 0, 1),
(19, 8, 1, 3, 1, 1, 1),
(20, 8, 2, 9, 3, 3, 3),
(21, 8, 3, 3, 1, 1, 1),
(22, 8, 4, 1, 0, 0, 1),
(23, 9, 1, 3, 1, 1, 1),
(24, 9, 2, 9, 3, 3, 3),
(25, 9, 3, 6, 2, 2, 2),
(26, 9, 4, 1, 0, 0, 1),
(27, 10, 1, 3, 1, 1, 1),
(28, 10, 2, 9, 3, 3, 3),
(29, 10, 3, 6, 2, 2, 2),
(30, 10, 4, 1, 0, 0, 1),
(31, 11, 1, 3, 1, 1, 1),
(32, 11, 2, 9, 3, 3, 3),
(33, 11, 3, 6, 2, 2, 2),
(34, 11, 4, 1, 0, 0, 1),
(35, 11, 5, 15, 5, 5, 5),
(36, 9, 5, 15, 5, 5, 5),
(37, 12, 1, 3, 1, 1, 1),
(38, 12, 2, 9, 3, 3, 3),
(39, 12, 3, 6, 2, 2, 2),
(40, 12, 4, 1, 0, 0, 1),
(41, 12, 5, 15, 5, 5, 5),
(42, 13, 1, 3, 1, 1, 1),
(43, 13, 2, 9, 3, 3, 3),
(44, 13, 3, 6, 2, 2, 2),
(45, 13, 4, 1, 0, 0, 1),
(46, 13, 5, 15, 5, 5, 5),
(47, 14, 1, 3, 1, 1, 1),
(48, 14, 2, 9, 3, 3, 3),
(49, 14, 3, 6, 2, 2, 2),
(50, 14, 4, 1, 0, 0, 1),
(51, 14, 5, 15, 5, 5, 5),
(52, 15, 1, 3, 1, 1, 1),
(53, 15, 2, 9, 3, 3, 3),
(54, 15, 3, 6, 2, 2, 2),
(55, 15, 4, 1, 0, 0, 1),
(56, 15, 5, 15, 5, 5, 5),
(58, 15, 7, 9, 3, 3, 3),
(60, 14, 7, 9, 3, 3, 3),
(62, 13, 7, 9, 3, 3, 3),
(64, 12, 7, 9, 3, 3, 3),
(65, 15, 8, 3, 1, 1, 1),
(66, 14, 8, 3, 1, 1, 1),
(67, 13, 8, 3, 1, 1, 1),
(68, 12, 8, 3, 1, 1, 1),
(69, 16, 1, 3, 1, 1, 1),
(70, 16, 2, 9, 3, 3, 3),
(71, 16, 3, 6, 2, 2, 2),
(72, 16, 4, 1, 0, 0, 1),
(73, 16, 5, 15, 5, 5, 5),
(74, 16, 7, 9, 3, 3, 3),
(75, 16, 8, 3, 1, 1, 1),
(76, 17, 1, 3, 1, 1, 1),
(77, 17, 2, 9, 3, 3, 3),
(78, 17, 3, 6, 2, 2, 2),
(79, 17, 4, 1, 0, 0, 1),
(80, 17, 5, 15, 5, 5, 5),
(81, 17, 7, 9, 3, 3, 3),
(82, 17, 8, 3, 1, 1, 1),
(83, 18, 1, 3, 1, 1, 1),
(84, 18, 2, 9, 3, 3, 3),
(85, 18, 3, 6, 2, 2, 2),
(86, 18, 4, 1, 0, 0, 1),
(87, 18, 5, 15, 5, 5, 5),
(88, 18, 7, 9, 3, 3, 3),
(89, 18, 8, 3, 1, 1, 1),
(90, 19, 1, 3, 1, 1, 1),
(91, 19, 2, 9, 3, 3, 3),
(92, 19, 3, 6, 2, 2, 2),
(93, 19, 4, 1, 0, 0, 1),
(94, 19, 5, 15, 5, 5, 5),
(95, 19, 7, 9, 3, 3, 3),
(96, 19, 8, 3, 1, 1, 1),
(97, 20, 1, 3, 1, 1, 1),
(98, 20, 2, 9, 3, 3, 3),
(99, 20, 3, 6, 2, 2, 2),
(100, 20, 4, 1, 0, 0, 1),
(101, 20, 5, 15, 5, 5, 5),
(102, 20, 7, 9, 3, 3, 3),
(103, 20, 8, 3, 1, 1, 1),
(104, 21, 1, 3, 1, 1, 1),
(105, 21, 2, 9, 3, 3, 3),
(106, 21, 3, 6, 2, 2, 2),
(107, 21, 4, 1, 0, 0, 1),
(108, 21, 5, 15, 5, 5, 5),
(109, 21, 7, 9, 3, 3, 3),
(110, 21, 8, 3, 1, 1, 1),
(111, 22, 1, 3, 1, 1, 1),
(112, 22, 2, 9, 3, 3, 3),
(113, 22, 3, 6, 2, 2, 2),
(114, 22, 4, 1, 0, 0, 1),
(115, 22, 5, 15, 5, 5, 5),
(116, 22, 7, 9, 3, 3, 3),
(117, 22, 8, 3, 1, 1, 1),
(118, 23, 1, 3, 1, 1, 1),
(119, 23, 2, 9, 3, 3, 3),
(120, 23, 3, 6, 2, 2, 2),
(121, 23, 4, 1, 0, 0, 1),
(122, 23, 5, 15, 5, 5, 5),
(123, 23, 7, 9, 3, 3, 3),
(124, 23, 8, 3, 1, 1, 1),
(125, 24, 1, 3, 1, 1, 1),
(126, 24, 2, 9, 3, 3, 3),
(127, 24, 3, 6, 2, 2, 2),
(128, 24, 4, 1, 0, 0, 1),
(129, 24, 5, 15, 5, 5, 5),
(130, 24, 7, 9, 3, 3, 3),
(131, 24, 8, 3, 1, 1, 1),
(132, 25, 1, 3, 1, 1, 1),
(133, 25, 2, 9, 3, 3, 3),
(134, 25, 3, 6, 2, 2, 2),
(135, 25, 4, 1, 0, 0, 1),
(136, 25, 5, 15, 5, 5, 5),
(137, 25, 7, 9, 3, 3, 3),
(138, 25, 8, 3, 1, 1, 1),
(139, 26, 1, 3, 1, 1, 1),
(140, 26, 2, 9, 3, 3, 3),
(141, 26, 3, 6, 2, 2, 2),
(142, 26, 4, 1, 0, 0, 1),
(143, 26, 5, 15, 5, 5, 5),
(144, 26, 7, 9, 3, 3, 3),
(145, 26, 8, 3, 1, 1, 1),
(146, 27, 1, 3, 1, 1, 1),
(147, 27, 2, 9, 3, 3, 3),
(148, 27, 3, 6, 2, 2, 2),
(149, 27, 4, 1, 0, 0, 1),
(150, 27, 5, 15, 5, 5, 5),
(151, 27, 7, 9, 3, 3, 3),
(152, 27, 8, 3, 1, 1, 1),
(153, 28, 1, 3, 1, 1, 1),
(154, 28, 2, 9, 3, 3, 3),
(155, 28, 3, 6, 2, 2, 2),
(156, 28, 4, 1, 0, 0, 1),
(157, 28, 5, 15, 5, 5, 5),
(158, 28, 7, 9, 3, 3, 3),
(159, 28, 8, 3, 1, 1, 1),
(160, 29, 1, 3, 1, 1, 1),
(161, 29, 2, 9, 3, 3, 3),
(162, 29, 3, 6, 2, 2, 2),
(163, 29, 4, 1, 0, 0, 1),
(164, 29, 5, 15, 5, 5, 5),
(165, 29, 7, 9, 3, 3, 3),
(166, 29, 8, 3, 1, 1, 1),
(167, 30, 1, 3, 1, 1, 1),
(168, 30, 2, 9, 3, 3, 3),
(169, 30, 3, 6, 2, 2, 2),
(170, 30, 4, 1, 0, 0, 1),
(171, 30, 5, 15, 5, 5, 5),
(172, 30, 7, 9, 3, 3, 3),
(173, 30, 8, 3, 1, 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `activity_types`
--

CREATE TABLE `activity_types` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(40) NOT NULL,
  `description` varchar(500) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `default_quarter_target` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `default_month1_target` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `default_month2_target` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `default_month3_target` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `weight` tinyint(3) UNSIGNED NOT NULL DEFAULT 0,
  `require_product` tinyint(1) NOT NULL DEFAULT 0,
  `created_datetime` datetime DEFAULT NULL,
  `updated_datetime` datetime DEFAULT NULL,
  `created_by_uid` bigint(20) UNSIGNED DEFAULT NULL,
  `updated_by_uid` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `activity_types`
--

INSERT INTO `activity_types` (`id`, `name`, `description`, `active`, `default_quarter_target`, `default_month1_target`, `default_month2_target`, `default_month3_target`, `weight`, `require_product`, `created_datetime`, `updated_datetime`, `created_by_uid`, `updated_by_uid`) VALUES
(1, 'ODP', 'One Day Promo', 1, 3, 1, 1, 1, 5, 1, NULL, '2025-09-10 11:30:56', NULL, 9),
(2, 'FM', 'Farmers Meeting', 1, 9, 3, 3, 3, 15, 1, NULL, '2025-09-10 11:30:34', NULL, 9),
(3, 'FT', 'Field Trip', 1, 6, 2, 2, 2, 25, 1, NULL, '2025-09-10 11:30:40', NULL, 9),
(4, 'FFD', 'Farm Field Day', 1, 1, 0, 0, 1, 30, 1, NULL, '2025-07-17 11:50:14', NULL, 9),
(5, 'Display Product', 'Display Product', 1, 15, 5, 5, 5, 10, 1, '2025-07-07 20:48:06', '2025-07-17 07:49:46', 9, 9),
(7, 'Branding', 'Branding Toko,Bandar,Petani', 1, 9, 3, 3, 3, 10, 0, '2025-07-17 11:46:19', '2025-09-10 11:30:20', 9, 9),
(8, 'Reporting', 'Laporan tepat waktu', 1, 3, 1, 1, 1, 5, 0, '2025-07-26 07:42:05', '2025-07-26 07:45:34', 9, 9);

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `type` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `shipping_address` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_datetime` datetime DEFAULT NULL,
  `updated_datetime` datetime DEFAULT NULL,
  `assigned_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_by_uid` bigint(20) UNSIGNED DEFAULT NULL,
  `updated_by_uid` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`id`, `name`, `type`, `phone`, `address`, `shipping_address`, `notes`, `active`, `created_datetime`, `updated_datetime`, `assigned_user_id`, `created_by_uid`, `updated_by_uid`) VALUES
(6, 'PT TANIGUNA MAHAKARYA', 'Distributor', '+62 811-450-210', 'The Gardens Blok Ci Jalan Pangeran Cakrabuana\nDesa/Kelurahan Kecomberan, Kec Talun Kab Cirebon Jawabarat', 'Jl. Raya Pasirmuncang, Kelurahan Munjul, Kec. Majalengka - Kota Majalengka', NULL, 1, '2025-07-17 21:28:19', NULL, 2, 9, NULL),
(7, 'TB BARA TANI', 'Distributor', '+62 811-450-210', 'The Gardens Blok Ci Jalan Pangeran Cakrabuana\nDesa/Kelurahan Kecomberan, Kec Talun Kab Cirebon Jawabarat', 'Jl. Raya Pasirmuncang, Kelurahan Munjul, Kec. Majalengka - Kota Majalengka', NULL, 1, '2025-07-17 21:29:48', NULL, 2, 9, NULL),
(8, 'CAHAYA TANI', 'R1', '+62 853-1644-7465', 'Panyingkiran, Majalengka', 'Majalengka', NULL, 1, '2025-08-06 09:26:37', '2025-08-06 09:29:01', 7, 2, 2),
(9, 'MANDIRI JAYA TANI', 'R1', '+62 821-2810-0887', 'Kurucuk , Kuningan', 'Kuningan', NULL, 1, '2025-08-06 09:27:50', '2025-09-18 14:25:00', 6, 2, 6),
(10, 'MULYA TANI', 'R2', '0822-1913-5346', 'Cirebon', 'Cirebon', NULL, 1, '2025-08-06 09:29:47', '2025-09-19 15:29:19', 5, 2, 5),
(11, 'FAJAR TANI MANDIRI', 'R1', '+62 813-9801-2417', 'Purwakarta', 'Purwakarta', NULL, 1, '2025-08-06 09:31:21', '2025-09-26 10:24:39', 8, 2, 8),
(12, 'UMI TANI', 'R2', '0857-2400-4846', 'Matanghaji,Cirebon', 'Cirebon', NULL, 1, '2025-08-07 17:20:44', '2025-09-19 15:29:08', 5, 5, 5),
(13, 'SOBAT TANI', 'R2', '085224088663', 'Jatitujuh Majalengka', NULL, NULL, 1, '2025-08-07 17:21:54', '2025-09-18 14:13:05', 7, 7, 7),
(14, 'RIZKIO TANI', 'R2', '0821-1647-5455', 'Cangkring,  cirebon', 'Cirebon', NULL, 1, '2025-08-07 17:22:53', '2025-09-19 15:29:45', 5, 5, 5),
(15, 'AGROTANI', 'R2', '081395850264', 'Kertajati', NULL, NULL, 1, '2025-08-07 17:23:24', '2025-09-18 14:10:05', 7, 7, 7),
(16, 'TANI MAKMUR', 'R2', '0821-1645-7311', 'Cirebon', 'Sindanglaut, cirebon', NULL, 1, '2025-08-07 17:24:18', '2025-09-19 15:30:42', 5, 5, 5),
(17, 'SINAR TANI', 'R2', '081324870525', 'Bantarwaru ligung', NULL, NULL, 1, '2025-08-07 17:24:45', '2025-09-18 14:12:47', 7, 7, 7),
(18, 'SUMBER TANI', 'R2', '0813-9588-8999', 'Sindanglaut, cirebon', 'Cirebon', NULL, 1, '2025-08-07 17:25:25', '2025-09-19 15:30:14', 5, 5, 5),
(19, 'DIAH LESTARI', 'R2', '0813-2133-1122', 'Sindanglaut, cirebon', 'Cirebon', NULL, 1, '2025-08-07 17:26:41', '2025-09-19 15:28:56', 5, 5, 5),
(20, 'SUCI MULYA TANI', 'R1', '0831-4743-2084', 'Ciledug, Cirebon', 'Cirebon', NULL, 1, '2025-08-07 17:28:47', '2025-09-19 15:29:59', 5, 5, 5),
(21, 'SUMBER TANI PALIMANAN', 'R2', '0899-9278-707', 'Palimanan, cirebon', 'Cirebon', NULL, 1, '2025-08-07 17:29:55', '2025-09-19 15:30:30', 5, 5, 5),
(22, 'RASIDIN TANI', 'R2', '0823-1756-7067', 'Girinata, cirebon', 'Cirebon', NULL, 1, '2025-08-07 17:31:29', '2025-09-19 15:29:33', 5, 5, 5),
(23, 'DERAS TANI', 'R2', '0895-4020-71400', 'Cirebon', 'Cirebon', NULL, 1, '2025-08-07 17:32:20', '2025-09-19 15:28:44', 5, 5, 5),
(24, 'ULYA TANI', 'R2', '0821-1790-3141', 'Dukupuntang,Cirebon', 'Cirebon', NULL, 1, '2025-08-07 17:33:21', '2025-09-26 11:18:05', 5, 5, 5),
(25, 'SUMBER REZEKI TANI', 'R2', NULL, 'Ligung', NULL, NULL, 1, '2025-08-07 17:41:04', '2025-09-18 14:13:50', 7, 7, 7),
(26, 'SAUNG TANI', 'R2', '082110002750', 'Majasari ligung', NULL, NULL, 1, '2025-08-07 17:42:13', '2025-09-18 14:12:30', 7, 7, 7),
(27, 'Tiga putri tani', 'R2', '085203008889', 'Banggalah kertajati', NULL, NULL, 1, '2025-08-07 17:43:46', '2025-08-07 20:10:39', 7, 7, 7),
(28, 'MAJU TANI', 'R2', '085353778747', 'Bantarjati', NULL, NULL, 0, '2025-08-07 17:44:17', '2025-09-18 14:10:53', 7, 7, 7),
(29, 'ATTA TANI', 'R2', '085223779233', 'GantarIndramayu', NULL, NULL, 1, '2025-08-07 17:45:39', '2025-09-18 14:10:32', 7, 7, 7),
(30, 'Tani Subur', 'R2', NULL, 'Purwakarta', 'Bojong, Purwakarta', NULL, 1, '2025-08-07 18:15:40', NULL, 8, 8, NULL),
(31, 'SRJS', 'R2', NULL, 'Purwakarta', 'Bojong, Purwakarta', NULL, 1, '2025-08-07 18:16:21', NULL, 8, 8, NULL),
(32, 'ILHAM TANI', 'R2', NULL, 'Purwakarta', 'Darangdan, Purwakarta', NULL, 1, '2025-08-07 18:16:55', '2025-09-26 10:24:51', 8, 8, 8),
(33, 'Rizky Tani', 'R2', '+62 899-9101-840', 'Purwakarta', 'Plered, Purwakarta', NULL, 1, '2025-08-07 18:17:46', NULL, 8, 8, NULL),
(34, 'Pengkolan Tani', 'R2', '+62 877-2000-5404', 'Purwakarta', 'Tegalwaru, Purwakarta', NULL, 1, '2025-08-07 18:18:32', NULL, 8, 8, NULL),
(35, 'DUA SATU', 'R2', '+62 812-8010-807', 'Purwakarta', 'Canpaka, Purwakarta', NULL, 1, '2025-08-07 18:19:07', '2025-09-26 10:24:26', 8, 8, 8),
(36, 'BUMI HIJAU MAKMUR', 'R2', '+62 831-2210-6321', 'Subang', 'Ciater, Subang', NULL, 1, '2025-08-07 18:19:53', '2025-09-26 10:24:16', 8, 8, 8),
(37, 'KUD RAHAYU', 'R2', '+62 852-2415-7292', 'Subang', 'Jalancagak, Subang', NULL, 1, '2025-08-07 18:20:45', '2025-09-26 10:25:19', 8, 8, 8),
(38, 'Tani Raharja', 'R2', '+62 878-2287-9876', 'Subang', 'Tanjungsiang, Subang', NULL, 1, '2025-08-07 18:21:41', NULL, 8, 8, NULL),
(39, 'BAROKAH TANI', 'R2', '+62 852-9458-6462', 'Subang', 'Tanjungsiang, Subang', NULL, 1, '2025-08-07 18:22:39', '2025-09-26 10:23:50', 8, 8, 8),
(40, 'Tani Meysha', 'R2', '+62 853-5244-8860', 'Subang', 'Kalijati, Subang', NULL, 1, '2025-08-07 18:24:10', NULL, 8, 8, NULL),
(41, 'BERKAH TANI', 'R2', '+62 857-9458-1784', 'Subang', 'Kalijati, Subang', NULL, 1, '2025-08-07 18:24:58', '2025-09-26 10:24:03', 8, 8, 8),
(42, 'UD Sumber Tani Gembor', 'R2', NULL, 'Subang', 'Pagaden, Subang', NULL, 0, '2025-08-07 18:25:44', NULL, 8, 8, NULL),
(43, 'Sumber Tani Jaya', 'R2', NULL, 'Subang', 'Cibogo, Subang', NULL, 0, '2025-08-07 18:26:49', NULL, 8, 8, NULL),
(44, 'PARVIS TANI', 'R2', '+62 853-5203-8017', 'Subang', 'Cikaum, Subang', NULL, 1, '2025-08-07 18:27:32', '2025-09-26 10:25:49', 8, 8, 8),
(45, 'MONA TANI', 'R2', NULL, 'Subang', 'Subang, Subang', NULL, 1, '2025-08-07 18:28:31', '2025-09-26 10:25:31', 8, 8, 8),
(46, 'KARYA MANDIRI', 'R2', '+62 857-5924-5588', 'Purwakarta', 'Campaka, Purwakarta', NULL, 1, '2025-08-07 18:29:44', '2025-09-26 10:25:07', 8, 8, 8),
(47, 'Sumber Mukti', 'R2', '+62 812-2371-2565', 'Subang', 'Tanjungsiang, Subang', NULL, 1, '2025-08-07 18:30:31', NULL, 8, 8, NULL),
(48, 'Utamatani', 'R2', NULL, 'Rajagaluh', NULL, NULL, 1, '2025-08-07 20:06:27', NULL, 7, 7, NULL),
(49, 'PUTRA NIAGA TANI', 'R2', '082310003929', 'JuntinyuatIndramayu', NULL, NULL, 0, '2025-08-07 20:07:00', '2025-09-18 14:12:14', 7, 7, 7),
(50, 'JAYA ABADI TANI', 'R2', '+62 812-2283-7755', 'Kramatmulya', 'Kuningan', NULL, 1, '2025-08-08 07:01:08', '2025-09-18 14:21:21', 6, 6, 6),
(51, 'MITRA TANI JALAKSANA', 'R2', '+62 812-1443-6968', 'Jalaksana', 'Kuningan', NULL, 0, '2025-08-08 07:07:06', '2025-09-18 14:27:14', 6, 6, 6),
(52, 'MAKMUR JAYA TANI', 'R2', '+62 853-2495-2141', 'Jalaksana', 'Kuningan', NULL, 0, '2025-08-08 07:09:30', '2025-09-18 14:24:19', 6, 6, 6),
(53, 'MEKAR JAYA TANI', 'R2', '+62 821-1688-5487', 'Cilimus', 'Kuningan', NULL, 0, '2025-08-08 07:11:46', '2025-09-18 14:25:42', 6, 6, 6),
(54, 'UD SAWARGI TANI', 'R2', '+62 897-1799-477', 'Mandirancan', 'Kuningan', NULL, 1, '2025-08-08 07:13:27', '2025-09-18 14:37:51', 6, 6, 6),
(55, 'JAYAMUKTI TANI', 'R2', '+62 853-1001-7880', 'Mandirancan', 'Kuningan', NULL, 1, '2025-08-08 07:17:18', '2025-09-18 14:21:58', 6, 6, 6),
(56, 'BERKAH TANI UTAMA', 'R2', '+62 812-1440-6075', 'Mandirancan', 'Kuningan', NULL, 0, '2025-08-08 07:20:41', '2025-09-18 14:16:07', 6, 6, 6),
(57, 'RAHAYU TANI', 'R2', '+62 813-2011-1177', 'Cidahu', 'Kuningan', NULL, 1, '2025-08-08 07:37:57', '2025-09-18 14:31:26', 6, 6, 6),
(58, 'SUKATANI SAE', 'R2', '+62 814-6116-1630', 'Cibingbin', 'Kuningan', NULL, 1, '2025-08-08 07:38:56', '2025-09-18 14:37:31', 6, 6, 6),
(59, 'LIZA TANI', 'R2', '+62 823-1626-2380', 'Maleber', 'Kuningan', NULL, 1, '2025-08-08 07:40:00', '2025-09-18 14:23:56', 6, 6, 6),
(60, 'CIMEK TANI', 'R2', '+62 852-2463-9555', 'Cikijing', 'Majalengka', NULL, 1, '2025-08-08 07:40:45', '2025-09-18 14:16:27', 6, 6, 6),
(61, 'RAYKA TANI', 'R2', '+62 852-1403-1125', 'Argapura', 'Majalengka', NULL, 1, '2025-08-08 07:41:37', '2025-09-18 14:31:46', 6, 6, 6),
(62, 'SHABIRA TANI', 'R2', '+62 813-1858-6297', 'Cikijing', 'Majalengka', NULL, 1, '2025-08-08 07:42:40', '2025-09-18 14:35:39', 6, 6, 6),
(63, 'ANUGERAH TANI', 'R2', '+62 853-2345-0215', 'Argapura', 'Majalengka', NULL, 1, '2025-08-08 07:43:26', '2025-09-18 14:13:32', 6, 6, 6),
(64, 'KIYA TANI', 'R2', '+62 812-2391-8334', 'Cikijing', 'Majalengka', NULL, 1, '2025-08-08 07:44:06', '2025-09-18 14:22:39', 6, 6, 6),
(65, 'AGRO TANI', 'R2', '+62 813-8399-5899', 'Bantarujeg', 'Majalengka', NULL, 1, '2025-08-08 07:44:53', '2025-09-18 14:11:24', 6, 6, 6),
(66, 'PRATAMA TANI', 'R2', '+62 812-9344-9476', 'Nusaherang', 'Kuningan', NULL, 1, '2025-08-08 07:45:48', '2025-11-14 07:52:19', 6, 6, 6),
(67, 'MUSTIKA MULYA TANI', 'R2', '+62 811-2228-188', 'Cikijing', 'Majalengka', NULL, 1, '2025-08-08 07:46:38', '2025-09-18 14:28:12', 6, 6, 6),
(68, 'AZKA TANI', 'R2', '+62 812-1263-6210', 'Cikijing', 'Majalengka', NULL, 1, '2025-08-08 07:47:31', '2025-09-18 14:14:19', 6, 6, 6),
(69, 'ADS TANI', 'R2', '+62 812-2472-3665', 'Malausma', 'Majalengka', NULL, 1, '2025-08-08 07:48:31', '2025-09-18 14:11:01', 6, 6, 6),
(70, 'RUDI TANI', 'R2', '+62 831-4256-7759', 'Jalaksana', 'Kuningan', NULL, 1, '2025-08-08 07:49:43', '2025-09-18 14:32:17', 6, 6, 6),
(71, 'BARAYA TANI', 'R2', '+62 811-2012-773', 'Argapura', 'Majalengka', NULL, 1, '2025-08-08 07:55:25', '2025-09-18 14:14:48', 6, 6, 6),
(72, 'NUSANTARA TANI', 'R2', '+62 819-3542-3306', 'Kadugede', 'Kuningan', NULL, 0, '2025-08-08 07:56:20', '2025-09-18 14:30:18', 6, 6, 6),
(73, 'DENTIS JAYA TANI', 'R2', '+62 857-9440-4896', 'Cikijing', 'Majalengka', NULL, 0, '2025-08-08 07:57:16', '2025-09-18 14:17:11', 6, 6, 6),
(74, 'ADE PARNO TANI', 'R2', '+62 896-9118-1631', 'Cingambul', 'Majalengka', NULL, 0, '2025-08-08 07:58:02', '2025-09-18 14:10:47', 6, 6, 6),
(75, 'SINAR ABADI TANI', 'R2', '+62 812-2447-4191', 'Cingambul', 'Majalengka', NULL, 0, '2025-08-08 07:59:07', '2025-09-18 14:36:08', 6, 6, 6),
(76, 'GUMILANG TANI', 'R2', '+62 813-2054-4274', 'Argapura', 'Majalengka', NULL, 0, '2025-08-08 07:59:57', '2025-09-18 14:20:36', 6, 6, 6),
(77, 'NANA TANI', 'R2', '+62 815-4698-3771', 'Jalaksana', 'Kuningan', NULL, 1, '2025-08-08 08:00:35', '2025-09-18 14:29:53', 6, 6, 6),
(78, 'EKA JAYA TANI', 'R2', '+62 896-4816-8719', 'Argapura', 'Majalengka', NULL, 1, '2025-08-08 08:01:25', '2025-09-18 14:17:40', 6, 6, 6),
(79, 'MUTIARA TANI', 'R2', '+62 882-2233-9416', 'Argapura', 'Majalengka', NULL, 1, '2025-08-08 08:02:26', '2025-09-18 14:29:23', 6, 6, 6),
(80, 'SELAMAT TANI', 'R2', '+62 852-2463-3306', 'Darma', 'Kuningan', NULL, 1, '2025-08-08 08:03:42', '2025-09-18 14:34:30', 6, 6, 6),
(81, 'SAHABAT TANI', 'R2', '+62 856-0381-2518', 'Cibingbin', 'Kuningan', NULL, 0, '2025-08-08 13:39:31', '2025-09-18 14:32:45', 6, 6, 6),
(82, 'BAROKAH TANI', 'R2', '+62 821-2836-1234', 'Kalimanggis', 'Kuningan', NULL, 0, '2025-08-08 13:40:44', '2025-09-18 14:15:09', 6, 6, 6),
(83, 'UKIM TANI', 'R2', '+62 812-2480-9111', 'Darma', 'Kuningan', NULL, 1, '2025-08-08 13:42:17', '2025-09-18 14:38:11', 6, 6, 6),
(84, 'SRI MULYA TANI', 'R2', '+62 877-9744-4303', 'Jalaksana', 'Kuningan', NULL, 1, '2025-08-08 13:43:03', '2025-09-18 14:36:55', 6, 6, 6),
(85, 'ANDALAN TANI', 'R2', '+62 852-1944-9023', 'Bantarujeg', 'Majalengka', NULL, 0, '2025-08-08 13:45:23', '2025-09-18 14:12:43', 6, 6, 6),
(86, 'AURA TANI', 'R2', '+62 853-5370-1335', 'Bantarujeg', 'Majalengka', NULL, 0, '2025-08-08 13:46:45', '2025-09-18 14:14:01', 6, 6, 6),
(87, 'SAWARGI TANI', 'R2', '+62 857-5970-3518', 'Lemahsugih', 'Majalengka', NULL, 1, '2025-08-08 13:47:30', '2025-09-18 14:33:41', 6, 6, 6),
(88, 'AGRO TANI SAGARAHIANG', 'R2', '+62 821-2332-3110', 'Darma', 'Kuningan', NULL, 0, '2025-08-08 13:48:13', '2025-09-18 14:11:55', 6, 6, 6),
(89, 'ENGGAL TANI', 'R2', '+62 853-1544-1006', 'Banjaran', 'Majalengka', NULL, 0, '2025-08-08 13:49:31', '2025-09-18 14:20:02', 6, 6, 6),
(90, 'MILDA TANI', 'R2', '+62 812-1489-3544', 'Banjaran', 'Majalengka', NULL, 1, '2025-08-08 13:50:20', '2025-09-18 14:26:25', 6, 6, 6),
(91, 'HOKKY TANI', 'R2', '+62 821-2871-3902', 'Kuningan', 'Kuningan', NULL, 0, '2025-08-08 13:51:12', '2025-09-18 14:20:57', 6, 6, 6),
(92, 'MUTIARA JAYA TANI', 'R2', '+62 823-2192-5239', 'Banjaran', 'Majalengka', NULL, 0, '2025-08-08 13:51:51', '2025-09-18 14:28:53', 6, 6, 6),
(93, 'AL TANI', 'R2', '+62 858-4662-8705', 'Lemahsugih', 'Majalengka', NULL, 0, '2025-08-08 13:52:29', '2025-09-18 14:12:17', 6, 6, 6),
(94, 'GN TANI', 'R2', '+62 821-1906-0799', 'Bantarujeg', 'Majalengka', NULL, 0, '2025-08-08 13:53:21', '2025-09-18 14:20:16', 6, 6, 6),
(95, 'MITRA TANI', 'R2', '+62 852-9848-2085', 'Maja', 'Majalengka', NULL, 1, '2025-08-08 13:54:01', '2025-09-18 14:26:49', 6, 6, 6),
(96, 'SINAR CAHAYA TANI', 'R2', '+62 821-1647-6468', 'Maja', 'Majalengka', NULL, 1, '2025-08-08 13:54:40', '2025-09-18 14:36:35', 6, 6, 6),
(97, 'KURNIA JAYA TANI', 'R2', '+62 821-1968-0318', 'Talaga', 'Majalengka', NULL, 0, '2025-08-08 13:55:41', '2025-09-18 14:23:07', 6, 6, 6),
(98, 'ENDIN TANI', 'R2', '+62 812-2082-3685', 'Cipulus', 'Majalengka', NULL, 1, '2025-08-08 13:56:29', '2025-09-18 14:19:39', 6, 6, 6),
(99, 'SAWARGI KAUM TANI', 'R2', '+62 857-2184-0161', 'Cibingbin', 'Kuningan', NULL, 0, '2025-08-08 13:57:10', '2025-09-18 14:27:37', 6, 6, 6),
(100, 'ABC TANI', 'R2', '+62 813-2110-7240', 'Banjaran', 'Majalengka', NULL, 1, '2025-08-08 13:57:49', '2025-09-18 14:10:13', 6, 6, 6),
(101, 'MEKUD TANI', 'R2', '+62 858-6491-0929', 'Luragung', 'Kuningan', NULL, 0, '2025-08-08 13:58:30', '2025-09-18 14:26:09', 6, 6, 6),
(102, 'WAJAM TANI', 'R2', '+62 813-2004-9147', 'Darma', 'Kuningan', NULL, 1, '2025-08-08 13:59:02', '2025-09-18 14:34:56', 6, 6, 6),
(103, 'BERKAH TANI 1', 'R2', '+62 838-7241-3290', 'Garawangi', 'Kuningan', NULL, 0, '2025-08-08 13:59:40', '2025-09-18 14:15:40', 6, 6, 6),
(104, 'SARANA TANI MAKMUR', 'R2', '+62 853-1873-6224', 'Lemahsugih', 'Majalengka', NULL, 1, '2025-08-08 14:00:13', '2025-09-18 14:33:22', 6, 6, 6),
(105, 'SETIA JAYA TANI', 'R2', '+62 821-1992-9268', 'Banjaran', 'Majalengka', NULL, 1, '2025-08-08 14:00:54', '2025-09-18 14:35:19', 6, 6, 6),
(106, 'KURNIA TANI', 'R2', '+62 813-2416-7953', 'Cikijing', 'Majalengka', NULL, 1, '2025-08-08 14:01:38', '2025-09-18 14:23:36', 6, 6, 6),
(107, 'ANEKA JAYA TANI', 'R2', '+62 853 2408 5859', 'Ds. Cihaur Kec. Maja Kab. Majalengka', 'Majalengka', NULL, 1, '2025-08-11 10:11:38', '2025-09-18 14:13:13', 6, 6, 6),
(108, 'SRI TANI', 'R2', '+62 823-1581-8881', 'Ds. Sidawangi Kec. Lemahsugih Kab. Majalengka', 'Majalengka', NULL, 1, '2025-08-15 12:53:54', '2025-09-18 14:37:12', 6, 6, 6),
(109, 'Pusaka Tani', 'R2', '086', 'Sumedang', NULL, NULL, 1, '2025-09-01 12:28:22', NULL, 13, 13, NULL),
(110, 'CV RACCOLTA AGRO INDONESIA', 'Distributor', '+62 811-450-210', 'Jln Raya Pasirmuncang,Kelurahan Munjul Kec. Majalengka ,Kota Majalengka', 'Jln Raya Pasirmuncang,Kelurahan Munjul Kec. Majalengka ,Kota Majalengka', NULL, 1, '2025-09-12 11:37:00', NULL, 2, 9, NULL),
(113, 'ADI JAYA', 'R2', '0821-2112-1514', 'Talun', 'Talun, cirebon', NULL, 1, '2025-09-17 20:10:42', '2025-09-19 15:28:29', 5, 5, 5),
(114, 'SULTAN FARM', 'R2', NULL, 'Ranji wetan', NULL, NULL, 1, '2025-09-18 06:41:37', '2025-09-18 14:13:23', 7, 7, 7),
(115, 'Mutiara Tani', 'R1', '081902895699', '53W6+486, Unnamed Road, Sarampad, Kec. Cugenang, Kabupaten Cianjur, Jawa Barat 43252', '53W6+486, Unnamed Road, Sarampad, Kec. Cugenang, Kabupaten Cianjur, Jawa Barat 43252', NULL, 1, '2025-10-02 12:39:15', '2025-10-03 16:14:16', 11, 11, 11),
(116, 'Tampomas Tani', 'R1', '082118388857', '62WW+JM8, Cipendawa, Kec. Pacet, Kabupaten Cianjur, Jawa Barat 43253\nPeta Tampomas Tani', '62WW+JM8, Cipendawa, Kec. Pacet, Kabupaten Cianjur, Jawa Barat 43253\nPeta Tampomas Tani', NULL, 1, '2025-10-03 16:15:27', NULL, 11, 11, NULL),
(117, 'Hikmah Tani', 'R1', NULL, 'Jalan Mariwati, Jl. Ciwalen pasar, Ciwalen, Kabupaten Cianjur, Jawa Barat 43254', 'Jalan Mariwati, Jl. Ciwalen pasar, Ciwalen, Kabupaten Cianjur, Jawa Barat 43254', NULL, 1, '2025-10-03 16:16:10', NULL, 11, 11, NULL),
(118, 'Pupuk Berkah', 'R1', NULL, '66J3+FC4, Kademangan, Kec. Mande, Kabupaten Cianjur, Jawa Barat 43292', '66J3+FC4, Kademangan, Kec. Mande, Kabupaten Cianjur, Jawa Barat 43292', NULL, 1, '2025-10-03 16:16:50', NULL, 11, 11, NULL),
(119, 'Putra Tani Makmur', 'R1', NULL, '543M+HJP, Sirnagalih, Kec. Cilaku, Kabupaten Cianjur, Jawa Barat 43285', '543M+HJP, Sirnagalih, Kec. Cilaku, Kabupaten Cianjur, Jawa Barat 43285', NULL, 1, '2025-10-03 16:22:09', NULL, 11, 11, NULL),
(120, 'DRAJAT TANI', 'R2', '+62 857-9390-1037', 'Ciawigebang', 'Kuningan', NULL, 1, '2025-11-12 19:12:22', '2025-11-14 07:34:32', 6, 6, 6),
(121, 'TANI RAHAYU', 'R2', NULL, 'Greged,beberapa, cirebon', NULL, NULL, 1, '2025-11-28 10:43:09', NULL, 5, 5, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `demo_plots`
--

CREATE TABLE `demo_plots` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `plant_date` date NOT NULL,
  `owner_name` varchar(100) NOT NULL,
  `owner_phone` varchar(40) DEFAULT NULL,
  `field_location` varchar(500) DEFAULT NULL,
  `population` bigint(20) UNSIGNED DEFAULT NULL,
  `latlong` varchar(100) DEFAULT NULL,
  `image_path` varchar(500) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `notes` text DEFAULT NULL,
  `plant_status` enum('not_yet_planted','not_yet_evaluated','satisfactory','unsatisfactory','completed','failed') NOT NULL DEFAULT 'not_yet_planted',
  `last_visit` date DEFAULT NULL,
  `created_datetime` datetime DEFAULT NULL,
  `updated_datetime` datetime DEFAULT NULL,
  `created_by_uid` bigint(20) UNSIGNED DEFAULT NULL,
  `updated_by_uid` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `demo_plots`
--

INSERT INTO `demo_plots` (`id`, `user_id`, `product_id`, `plant_date`, `owner_name`, `owner_phone`, `field_location`, `population`, `latlong`, `image_path`, `active`, `notes`, `plant_status`, `last_visit`, `created_datetime`, `updated_datetime`, `created_by_uid`, `updated_by_uid`) VALUES
(12, 8, 2, '2025-06-02', 'Kang Ujang', NULL, 'Ciater, Subang', 6000, NULL, 'uploads/1756704223_PhotoGrid_Plus_1756704181617.jpg', 0, 'Penanaman 4bungkus\r\nKetinggian +-995mdpl', 'completed', '2025-09-03', '2025-07-14 10:45:59', '2025-09-03 13:45:48', 8, 8),
(13, 8, 2, '2025-05-03', 'Pak Eka', NULL, 'Darangdan, Purwakarta', NULL, NULL, 'uploads/1752464974_20250702_125032.jpg', 0, NULL, 'completed', '2025-07-24', '2025-07-14 10:49:35', '2025-07-27 20:57:36', 8, 9),
(14, 8, 8, '2025-05-30', 'Pak Yana', NULL, 'Wanayasa, Purwakarta', 500, NULL, 'uploads/1752465087_20250618_105154.jpg', 0, NULL, 'completed', '2025-08-12', '2025-07-14 10:51:28', '2025-09-09 22:04:13', 8, 8),
(15, 8, 11, '2025-05-27', 'Pak Dede', NULL, 'Jalancagak, Subang', 1000, NULL, 'uploads/1752465261_20250623_144252.jpg', 0, NULL, 'unsatisfactory', '2025-07-22', '2025-07-14 10:54:22', '2025-10-21 18:09:17', 8, 8),
(16, 8, 8, '2025-06-23', 'Pak Iwan', NULL, 'Ciater, Subang', 1500, NULL, 'uploads/1753795811_20250616_161231.jpg', 0, 'Penanaman 1 bungkus', 'not_yet_planted', NULL, '2025-07-14 10:56:22', '2025-10-21 18:09:53', 8, 8),
(18, 6, 8, '2025-06-20', 'Pak Jaja', '+62 853-1688-5409', 'Ds. Sidamulya Kec. Jalaksana Kab. Kuningan', 1500, '-6.929596922538542,108.47356735806993', 'uploads/1755765775_IMG_1768.jpeg', 0, 'Dijadikan Field Trip', 'completed', '2025-09-09', '2025-07-14 12:32:37', '2025-09-09 16:16:38', 6, 6),
(19, 6, 2, '2025-06-01', 'Pak Suhali', '+62 823-2071-4008', 'Ds. Sukamukti Kec. Jalaksana Kab. Kuningan', 6000, '-6.935146162560092,108.45132991154492', 'uploads/1756261609_IMG_2142.jpeg', 0, 'Dijadikan FFD', 'completed', '2025-09-09', '2025-07-14 14:47:26', '2025-09-09 16:15:17', 6, 6),
(20, 6, 2, '2025-05-05', 'Pak Saman', NULL, 'Ds. Gandasoli Kec. Kramatmulya Kab. Kuningan', 1000, NULL, 'uploads/1752482482_IMG_0688.jpeg', 0, NULL, 'completed', '2025-07-14', '2025-07-14 15:41:23', '2025-08-07 14:57:46', 6, 6),
(21, 7, 7, '2025-06-10', 'Tirta', '-', 'Ligung', 100, NULL, 'uploads/1754400467_1000483037.jpg', 0, 'Tanam sampel 100 gram', 'satisfactory', '2025-07-18', '2025-07-14 20:29:33', '2025-10-05 10:40:31', 7, 7),
(22, 7, 10, '2025-07-10', 'Abah harun', '-', 'Karyamukti', 1000, NULL, 'uploads/1757478164_1000532051.jpg', 1, 'Tanam 20pcs tanpa lanjaran', 'satisfactory', '2025-08-01', '2025-07-14 20:30:39', '2025-09-10 11:22:44', 7, 7),
(23, 7, 2, '2025-06-15', 'Pak dede', '-', 'Karang anyar', 1, NULL, NULL, 0, NULL, 'completed', '2025-09-09', '2025-07-14 20:32:36', '2025-09-09 15:58:31', 7, 7),
(24, 7, 1, '2025-05-17', 'Pak taspi', '-', 'Ligung', NULL, NULL, 'uploads/1752752721_1000241543.png', 0, NULL, 'completed', '2025-07-24', '2025-07-14 20:33:51', '2025-07-27 20:57:13', 7, 9),
(25, 7, 1, '2025-05-14', 'Pak maman', '-', 'Majasuka', 11, NULL, 'uploads/1754390919_1000480019.jpg', 0, NULL, 'completed', '2025-07-24', '2025-07-14 20:35:18', '2025-08-05 17:48:39', 7, 7),
(26, 7, 11, '2025-05-05', 'Sud', NULL, 'Majasari', 1500, NULL, 'uploads/1754400991_1000483038.jpg', 1, NULL, 'satisfactory', '2025-08-05', '2025-07-14 20:37:42', '2025-08-05 20:36:32', 7, 7),
(27, 5, 4, '2025-06-28', 'Agus', '0821-1332-6123', 'Pabedilan', 900, NULL, 'uploads/1752505924_IMG20250619130343.jpg', 0, NULL, 'unsatisfactory', '2025-07-14', '2025-07-14 22:12:04', '2025-09-09 20:27:59', 5, 5),
(28, 5, 1, '2025-06-18', 'Agus', '0821-1332-6123', 'Pabedilan', 7000, NULL, 'uploads/1752506284_IMG20250630110603.jpg', 0, NULL, 'completed', '2025-09-04', '2025-07-14 22:18:04', '2025-09-09 20:24:30', 5, 5),
(29, 5, 1, '2025-07-01', 'Agus', '0821-1332-6123', 'Pabedilan', 7000, NULL, 'uploads/1752506364_IMG20250620093532.jpg', 0, NULL, 'completed', '2025-09-04', '2025-07-14 22:19:25', '2025-09-09 20:27:11', 5, 5),
(30, 5, 2, '2025-05-09', 'Arifin', '-', 'Pabedilan', 10, NULL, 'uploads/1752506449_IMG20250714101200.jpg', 0, NULL, 'completed', '2025-07-17', '2025-07-14 22:20:49', '2025-09-09 20:34:42', 5, 5),
(31, 5, 1, '2025-09-16', 'Pak haji Opic Cecep pabuaran', NULL, 'Pabedilan', 28000, NULL, 'uploads/1758844531_IMG20250924165156.jpg', 0, 'Penanaman 1 dus Lilac namun benih disebar diseting perhari tertanam 5-10 bungkus', 'satisfactory', '2025-09-24', '2025-07-14 22:23:23', '2025-11-28 10:41:17', 5, 5),
(32, 5, 2, '2025-05-10', 'Pak conot', '-', 'Gebang', 8, NULL, 'uploads/1752506901_IMG20250623104416.jpg', 0, NULL, 'completed', '2025-07-16', '2025-07-14 22:28:21', '2025-09-09 20:35:10', 5, 5),
(33, 5, 2, '2025-05-10', 'Witro', '-', 'Hulubanteng', NULL, NULL, 'uploads/1752506970_IMG20250626143026.jpg', 0, NULL, 'completed', '2025-07-21', '2025-07-14 22:29:30', '2025-07-27 20:57:46', 5, 9),
(34, 5, 2, '2025-05-17', 'Komarudin', '0857-4682-0175', 'Palimanan', 28, NULL, 'uploads/1752507223_IMG20250616102641.jpg', 0, 'Tanaman tidak kondusif kekeringanairdan pas hujan turun kerendem 1 minggu', 'failed', '2025-07-16', '2025-07-14 22:33:43', '2025-09-09 20:37:44', 5, 5),
(35, 5, 1, '2025-06-05', 'Kadari', NULL, 'Palimanan', 20, NULL, 'uploads/1752507438_IMG-20250714-WA0069.jpg', 0, NULL, 'failed', '2025-08-12', '2025-07-14 22:37:19', '2025-09-09 20:28:49', 5, 5),
(36, 5, 2, '2025-05-04', 'Adi', '0813-2497-0046', 'Talun', 13, NULL, 'uploads/1752507550_IMG20250714115456.jpg', 0, NULL, 'completed', '2025-07-28', '2025-07-14 22:39:11', '2025-09-09 20:36:30', 5, 5),
(37, 5, 1, '2025-05-31', 'Adi', '813-2497-0046', 'Talun', 12, NULL, 'uploads/1752507591_IMG20250714115858.jpg', 0, NULL, 'completed', '2025-08-12', '2025-07-14 22:39:51', '2025-09-09 20:32:02', 5, 5),
(38, 5, 2, '2025-05-26', 'Adi', '0813-2497-0046', 'Wanasaba', 12, NULL, 'uploads/1752507687_IMG20250712105543.jpg', 0, NULL, 'completed', '2025-08-12', '2025-07-14 22:41:28', '2025-09-09 20:31:21', 5, 5),
(39, 5, 2, '2025-05-22', 'Adi', '0813-2497-0046', 'Cirebon', 15, NULL, 'uploads/1752507754_IMG20250701143828.jpg', 0, NULL, 'completed', '2025-08-12', '2025-07-14 22:42:34', '2025-09-09 20:30:52', 5, 5),
(40, 5, 2, '2025-05-12', 'Erwan', NULL, 'Waled', 7, NULL, 'uploads/1752507954_IMG20250513133049.jpg', 0, NULL, 'completed', '2025-07-26', '2025-07-14 22:45:55', '2025-09-09 20:36:59', 5, 5),
(41, 6, 9, '2025-06-11', 'Pak Utis', NULL, 'Blok Gunung Tengah, Ds. Sukadana Kec. Argapura Kab. Majalengka', 1400, NULL, 'uploads/1757590122_IMG_2609.jpeg', 0, NULL, 'completed', '2025-09-11', '2025-07-16 13:51:17', '2025-11-14 09:41:33', 6, 6),
(42, 6, 9, '2025-05-05', 'Pak Sur', '+62 852-9580-3434', 'Ds. Cikaracak Kec. Argapura Kab. Majalengka', 1400, NULL, 'uploads/1756042516_IMG_1943.jpeg', 0, 'Dijadikan Field Trip (FT)', 'completed', '2025-09-09', '2025-07-16 14:32:25', '2025-09-09 16:20:55', 6, 6),
(43, 6, 9, '2025-06-11', 'Pak Maman', '+62 852-2426-5060', 'Ds. Argalingga Kec. Argapura Kab. Majalengka', 1000, NULL, 'uploads/1756043279_IMG_1899.jpeg', 0, NULL, 'completed', '2025-08-22', '2025-07-16 14:40:08', '2025-10-10 10:37:54', 6, 6),
(44, 6, 9, '2025-08-05', 'Pak Feri', '+62 822-6024-7578', 'Ds. Argalingga Kec. Argapura Kab. Majalengka', 2800, NULL, 'uploads/1756043005_IMG_1903.jpeg', 0, NULL, 'failed', '2025-08-22', '2025-07-16 17:45:09', '2025-10-30 21:26:38', 6, 6),
(45, 6, 9, '2025-06-20', 'Pak Feri', '+62 822-6024-7578', 'Ds. Argalingga Kec. Argapura Kab. Majalengka', 500, NULL, 'uploads/1756042697_IMG_1904.jpeg', 0, NULL, 'completed', '2025-08-22', '2025-07-16 17:46:39', '2025-10-10 10:32:43', 6, 6),
(46, 6, 9, '2025-07-01', 'Pak Maman', '+62 852-2426-5060', 'Ds. Argalingga Kec. Argapura Kab. Majalengka', 1400, NULL, 'uploads/1756043178_IMG_1902.jpeg', 0, NULL, 'completed', '2025-08-22', '2025-07-16 17:49:04', '2025-10-10 10:38:53', 6, 6),
(47, 7, 10, '2025-07-21', 'Pak tata', '-', 'Cipadung', 3300, NULL, 'uploads/1758844351_1000552832.jpg', 1, 'Tanam 65 pcs', 'satisfactory', '2025-09-26', '2025-07-16 20:36:39', '2025-09-26 06:52:41', 7, 7),
(48, 5, 2, '2025-05-26', 'MasHadi', NULL, 'Megu, cirebon', 14, NULL, 'uploads/1757942869_IMG20250804121018.jpg', 0, NULL, 'completed', '2025-08-11', '2025-07-16 22:04:00', '2025-09-15 20:27:49', 5, 5),
(49, 5, 1, '2025-05-26', 'Mas hadi', NULL, 'Weru, cirebon', 12, NULL, 'uploads/1757848658_IMG20250802150023.jpg', 0, NULL, 'completed', '2025-08-03', '2025-07-16 22:07:29', '2025-09-14 18:17:38', 5, 5),
(50, 5, 2, '2025-05-22', 'Mang likun', NULL, 'Megu', 4, NULL, 'uploads/1757848539_IMG20250728103424.jpg', 0, NULL, 'completed', '2025-07-30', '2025-07-16 22:10:08', '2025-09-14 18:15:39', 5, 5),
(51, 5, 1, '2025-05-19', 'Mang likun', NULL, 'Megu', 4, NULL, 'uploads/1757848068_IMG20250725115500.jpg', 0, NULL, 'completed', '2025-07-28', '2025-07-16 22:12:16', '2025-09-14 18:07:48', 5, 5),
(52, 5, 1, '2025-05-27', 'Mang kasa', NULL, 'Pangenan', 9, NULL, 'uploads/1757848961_IMG20250614112641.jpg', 0, NULL, 'completed', '2025-07-18', '2025-07-16 22:15:34', '2025-09-14 18:22:41', 5, 5),
(53, 5, 1, '2025-05-27', 'Basyar', NULL, 'Losari, cirebon', 9, NULL, 'uploads/1757848407_IMG20250729091933.jpg', 0, NULL, 'completed', '2025-08-01', '2025-07-16 22:20:25', '2025-09-14 18:13:28', 5, 5),
(54, 5, 4, '2025-06-02', 'Basyar', NULL, 'Losari, cirebon', 1, NULL, 'uploads/1757848228_IMG20250729111538.jpg', 0, NULL, 'unsatisfactory', '2025-07-29', '2025-07-16 22:21:06', '2025-09-14 18:10:28', 5, 5),
(55, 5, 4, '2025-06-16', 'Tarkim', NULL, 'Pabuaran', 3500, NULL, 'uploads/1757943427_IMG20250826145202.jpg', 0, NULL, 'completed', '2025-09-01', '2025-07-16 22:21:59', '2025-09-15 20:37:07', 5, 5),
(56, 5, 4, '2025-07-03', 'Pak arun', NULL, 'Pabedilan', 900, NULL, 'uploads/1757944326_IMG20250819141329.jpg', 0, 'Tidak terkawal sampai ahir', 'satisfactory', '2025-08-21', '2025-07-16 22:22:48', '2025-09-15 20:52:07', 5, 5),
(57, 5, 4, '2025-08-12', 'Udin cikulak', NULL, 'Cikulak', 2, NULL, 'uploads/1757944482_IMG-20250915-WA0067.jpg', 0, 'Baru disebar benih samplenya', 'satisfactory', '2025-09-24', '2025-07-16 22:23:46', '2025-11-13 00:00:18', 5, 5),
(58, 5, 2, '2025-08-14', 'Diding', NULL, 'KubangTalun, cirebon', 10500, NULL, 'uploads/1757945024_IMG-20250915-WA0069.jpg', 0, NULL, 'satisfactory', '2025-10-24', '2025-07-16 22:24:22', '2025-11-12 23:47:23', 5, 5),
(59, 5, 1, '2025-08-22', 'Hadi', NULL, 'Weru,Cirebon', 12, NULL, 'uploads/1757943611_IMG20250909110913.jpg', 0, 'Penanaman dilahan pertama', 'satisfactory', '2025-10-24', '2025-07-16 22:25:00', '2025-11-13 00:21:54', 5, 5),
(60, 5, 2, '2025-06-26', 'Likun', NULL, 'Weru', 7000, NULL, 'uploads/1757849281_IMG20250904165957.jpg', 0, 'Jagung madu', 'completed', '2025-09-09', '2025-07-16 22:25:30', '2025-09-23 20:48:20', 5, 5),
(61, 6, 9, '2025-07-10', 'Pak Maman', '+62 852-2426-5060', 'Ds. Argalingga Kec. Argapura Kab. Majalengka', 1000, '-6.882797862011865,108.36159464717728', 'uploads/1752710428_IMG_0775.jpeg', 0, NULL, 'completed', '2025-07-16', '2025-07-17 07:00:29', '2025-10-10 10:33:39', 6, 6),
(62, 6, 8, '2025-07-10', 'Pak Maman', '+62 852-2426-5060', 'Ds. Argalingga Kec. Argapura Kab. Majalengka', 1000, NULL, 'uploads/1752710559_IMG_0776.jpeg', 0, NULL, 'completed', '2025-07-16', '2025-07-17 07:02:39', '2025-10-10 10:33:59', 6, 6),
(63, 5, 2, '2025-05-08', 'Erwan', NULL, 'Cikulak', 7, NULL, 'uploads/1757944178_IMG20250718114557.jpg', 0, NULL, 'completed', '2025-07-24', '2025-07-18 13:55:34', '2025-09-15 20:49:39', 5, 5),
(64, 5, 4, '2025-07-18', 'Suha', NULL, 'Cikulak', 3600, NULL, 'uploads/1757944909_IMG20250826135735_01.jpg', 0, 'Penanaman sample reva 2 bungkus danAnaraw bungkus ditanam hariMinggu 20 juli 2025', 'satisfactory', '2025-09-29', '2025-07-18 13:58:58', '2025-10-16 20:42:42', 5, 5),
(65, 7, 7, '2025-06-10', 'Abah maun', NULL, 'Ligung', NULL, NULL, NULL, 0, NULL, 'unsatisfactory', '2025-07-19', '2025-07-19 08:54:28', '2025-08-01 23:06:25', 7, 7),
(66, 7, 1, '2025-06-16', 'Gone', '083179741123', 'Palasah', 10, NULL, 'uploads/1754544932_1000485357.jpg', 0, NULL, 'completed', '2025-08-26', '2025-07-19 08:57:55', '2025-08-26 09:43:09', 7, 7),
(67, 7, 4, '2025-07-20', 'Pak Nur', NULL, 'Cibentar', 3200, NULL, 'uploads/1759229952_1000558422.jpg', 0, NULL, 'completed', '2025-10-05', '2025-07-19 09:02:08', '2025-10-05 10:45:52', 7, 7),
(68, 7, 6, '2025-08-08', 'Pak darma', NULL, 'Banggalah kertajati', 2, NULL, 'uploads/1756971905_1000524280.jpg', 0, 'Tanam 2 pcs', 'satisfactory', '2025-09-04', '2025-07-19 09:04:13', '2025-10-05 10:40:58', 7, 7),
(69, 7, 1, '2025-05-30', 'Pak kaman', NULL, 'Parapatan sumberjaya', 1, NULL, 'uploads/1754400853_1000483066.jpg', 0, 'Tanam 11pcs', 'completed', '2025-08-05', '2025-07-21 20:30:28', '2025-08-07 06:57:37', 7, 7),
(70, 7, 7, '2025-06-11', 'Pak darma', NULL, 'Kertajati', 1, NULL, NULL, 0, NULL, 'completed', '2025-09-09', '2025-07-22 05:19:36', '2025-09-09 20:31:55', 7, 7),
(71, 6, 8, '2025-07-25', 'Pak Odih', '+62 822-1508-4060', 'Ds. Sedareja Kec. Cingambul Kab. Majalengka', 1400, NULL, 'uploads/1759324723_IMG-20251001-WA0004.jpg', 0, 'Dijadikan field trip', 'completed', '2025-10-01', '2025-07-22 08:40:33', '2025-10-30 21:34:03', 6, 6),
(72, 6, 8, '2025-05-27', 'Pak Ihin', '+62 823-1759-5555', 'Ds. Sangiang Kec. Banjaran Kab. Majalengka', 1000, NULL, 'uploads/1755766062_IMG_1549.jpeg', 0, NULL, 'completed', '2025-09-09', '2025-07-22 10:23:03', '2025-09-09 16:23:16', 6, 6),
(73, 8, 11, '2025-09-24', 'Pak Mantri Andi', NULL, 'Ciater, Subang', 6000, NULL, 'uploads/1763009083_PhotoGrid_Plus_1763008846323.jpg', 1, NULL, 'satisfactory', '2025-11-13', '2025-07-22 17:08:57', '2025-11-13 11:44:43', 8, 8),
(74, 6, 8, '2025-06-17', 'Pak Ihin', '+62 823-1759-5555', 'Ds. Sangiang Kec. Banjaran Kab. Majalengka', 500, NULL, 'uploads/1755765880_IMG_1585.jpeg', 0, NULL, 'completed', '2025-08-13', '2025-07-22 20:10:54', '2025-10-10 10:35:33', 6, 6),
(75, 6, 8, '2025-07-22', 'Pak Udin', '+62 852-2437-6355', 'Ds. Cisantana Kec. Cigugur Kab. Kuningan', 3000, NULL, 'uploads/1753190127_IMG_0957.jpeg', 0, NULL, 'completed', '2025-07-29', '2025-07-22 20:15:28', '2025-09-30 16:17:17', 6, 6),
(76, 6, 9, '2025-07-22', 'Pak Imam', '+62 896-7692-0136', 'Ds. Cisantana Kec. Cigugur Kab. Kuningan', 3000, NULL, 'uploads/1753772708_3C2ACAA9-D4D8-44AD-A9A5-F67FCC6DE8A5.jpeg', 0, 'Tidak Tumbuh', 'failed', '2025-07-29', '2025-07-22 20:17:24', '2025-08-07 14:52:13', 6, 6),
(77, 6, 11, '2025-07-11', 'Pak Dinar', '+62 813-1262-7078', 'Ds. Sagarahiang Kec. Darma Kab. Kuningan', 1000, NULL, 'uploads/1753667843_IMG_1076.jpeg', 0, NULL, 'completed', '2025-07-28', '2025-07-28 08:57:24', '2025-12-05 21:21:26', 6, 6),
(78, 7, 6, '2025-06-22', 'Pak otong', NULL, 'Banggalah Kertajati', 1, NULL, 'uploads/1754400360_1000483040.jpg', 0, 'Tanam 1pcs', 'completed', '2025-09-10', '2025-07-28 09:01:54', '2025-09-10 05:15:51', 7, 7),
(80, 7, 7, '2025-06-11', 'Pak sule', NULL, 'BanggalaKertajati', 400, NULL, 'uploads/1755661371_1000503275.jpg', 0, NULL, 'completed', '2025-08-20', '2025-07-28 09:07:00', '2025-08-26 09:43:49', 7, 7),
(81, 5, 1, '2025-05-24', 'Pak adi', NULL, 'Wanasaba, baso mamah sarah', 4, NULL, 'uploads/1757942743_IMG20250804121054.jpg', 0, NULL, 'completed', '2025-08-12', '2025-07-28 14:04:09', '2025-09-15 20:25:43', 5, 5),
(82, 5, 2, '2025-06-25', 'Pak adi', NULL, 'Wanasaba, belakang bengkel', 21000, NULL, 'uploads/1757946064_IMG20250904165932.jpg', 0, 'Penanaman 12 bungkus', 'satisfactory', '2025-09-07', '2025-07-28 14:05:48', '2025-09-15 21:21:05', 5, 5),
(83, 5, 2, '2025-06-12', 'Pak adi', NULL, 'CempakaArum, perumahan', 21000, NULL, 'uploads/1757943075_IMG20250820124157.jpg', 0, NULL, 'completed', '2025-09-04', '2025-07-28 14:07:02', '2025-09-15 20:31:16', 5, 5),
(84, 7, 12, '2025-07-26', 'Pak Mama', NULL, 'Panyingkiran', 500, '-6.8028914,108.1747732', 'uploads/1758955941_1000554617.jpg', 1, 'Madu,exotic,H72 (100 gr)', 'satisfactory', '2025-09-27', '2025-07-28 16:08:29', '2025-09-27 13:52:35', 7, 7),
(85, 8, 11, '2025-08-19', 'Pak Rosidin', NULL, 'Ciater, Subang', 2000, NULL, 'uploads/1761889302_PhotoGrid_Plus_1761888868687.jpg', 1, 'Penanaman 2 bungkus DB 50%', 'satisfactory', '2025-10-31', '2025-07-28 16:18:16', '2025-10-31 12:41:42', 8, 8),
(86, 7, 2, '2025-04-27', 'Pak dede', NULL, 'Karang anyar', NULL, NULL, 'uploads/1753757873_Screenshot_20250729-095722.png', 0, NULL, 'completed', '2025-07-09', '2025-07-29 06:56:05', '2025-07-29 09:57:53', 7, 9),
(87, 7, 2, '2025-01-27', 'Pak emen', '082116833321', 'Cijurey', NULL, NULL, 'uploads/1753795292_IMG-20250729-WA0034.jpg', 0, NULL, 'completed', '2025-04-08', '2025-07-29 12:09:57', '2025-07-29 20:21:32', 7, 7),
(88, 6, 11, '2025-02-06', 'Pak Erwin', '+62 813-3727-9877', 'Ds. Borogojol Kec. Lemahsugih Kab. Majalengka', 1000, NULL, 'uploads/1753765952_IMG_4810.jpeg', 0, NULL, 'completed', '2025-07-29', '2025-07-29 12:12:33', '2025-08-07 14:45:21', 6, 6),
(89, 7, 7, '2025-03-06', 'Pak tata', NULL, 'Karyamukti', NULL, NULL, 'uploads/1753792259_IMG-20250428-WA0024.jpg', 0, NULL, 'completed', '2025-05-05', '2025-07-29 12:18:22', '2025-07-29 19:31:00', 7, 7),
(90, 6, 6, '2025-04-26', 'Pak Ade', '+62 817-9081-745', 'Ds. Gunung Karung Kec. Luragung Kab. Kuningan', 19000, NULL, 'uploads/1753772552_05a3d94c-9b21-470e-a354-e81e7baa7e61.jpeg', 0, 'Dijadikan Farmer Field Day dan Field Trip', 'completed', '2025-06-03', '2025-07-29 12:19:04', '2025-08-07 14:51:20', 6, 6),
(91, 7, 10, '2025-05-04', 'Pak tata', NULL, 'Panyingkiran', NULL, NULL, 'uploads/1753792132_IMG-20250623-WA0004.jpg', 0, NULL, 'completed', '2025-07-18', '2025-07-29 12:37:08', '2025-07-29 19:28:52', 7, 7),
(92, 6, 6, '2025-04-23', 'Pak Endi', '+62 878-8400-0112', 'Ds. Sindang Panji Kec. Cikijing Kab. Majalengka', 2100, NULL, 'uploads/1753767749_e923fbad-9c81-4a4f-814b-c8f6cf0597cc.jpeg', 0, NULL, 'completed', '2025-06-17', '2025-07-29 12:42:29', '2025-08-07 14:46:22', 6, 6),
(93, 6, 6, '2025-05-11', 'Pak Edi', NULL, 'Ds. Cikandang Kec. Luragung Kab. Kuningan', 6800, NULL, 'uploads/1753769745_4de66a8d-0570-4e2c-92c4-3443f33f3255.jpeg', 0, NULL, 'completed', '2025-07-29', '2025-07-29 13:15:46', '2025-08-07 14:50:27', 6, 6),
(94, 6, 8, '2025-04-01', 'Pak Wawan', '+62 813-1254-5711', 'Ds. Cipulus Kec. Cikijing Kab. Majalengka', 4200, NULL, 'uploads/1753770093_0116c44e-bf2d-4610-a381-ab89dd13070d.jpeg', 0, 'Dijadikan Field Trip (FT)', 'completed', '2025-06-21', '2025-07-29 13:21:33', '2025-08-07 14:49:34', 6, 6),
(95, 6, 2, '2025-04-13', 'Pak Darwa', NULL, 'Ds. Gunung Karung Kec. Luragung Kab. Kuningan', 1500, NULL, 'uploads/1753770525_689e4444-9d29-413e-9096-2859f70a3e61.jpeg', 0, 'Dijadikan FT', 'completed', '2025-07-04', '2025-07-29 13:28:45', '2025-08-07 14:48:41', 6, 6),
(96, 6, 5, '2025-05-27', 'Pak Rahul', '+62 853-1756-3995', 'Ds. Babakanmulya Kec. Jalaksana Kab. Majalengka', 8160, NULL, 'uploads/1753770954_c49cc1c5-e292-4941-960f-9099d1cefd3e.jpeg', 0, NULL, 'completed', '2025-06-20', '2025-07-29 13:35:54', '2025-08-07 14:47:52', 6, 6),
(97, 8, 8, '2025-08-07', 'Kang Aji', NULL, 'Ciater, Subang', 1500, NULL, 'uploads/1759471245_PhotoGrid_Plus_1759471029635.jpg', 0, 'Penanaman 1 bungkus', 'satisfactory', '2025-10-03', '2025-07-29 13:41:51', '2025-11-19 08:59:57', 8, 8),
(98, 6, 9, '2025-03-21', 'Pak Maman', NULL, 'Ds. Cipulus Kec. Cikijing Kab. Majalengka', 500, NULL, 'uploads/1753771360_1341faf1-cc99-4e86-ae06-437493b73378.jpeg', 0, NULL, 'completed', '2025-06-21', '2025-07-29 13:42:40', '2025-08-07 14:47:02', 6, 6),
(99, 8, 6, '2025-03-25', 'Pak Ikin', NULL, 'Darangdan, Purwakarta', NULL, NULL, 'uploads/1753793591_20250430_105708.jpg', 0, 'Penanaman 3 bungkus', 'completed', '2025-04-30', '2025-07-29 19:53:13', '2025-07-29 20:01:15', 8, 8),
(100, 8, 8, '2025-03-17', 'Pak Eka', NULL, 'Darangdan, Purwakarta', NULL, NULL, 'uploads/1753793901_20250423_115625.jpg', 0, 'Penanaman 2 bungkus', 'completed', '2025-05-14', '2025-07-29 19:58:22', '2025-07-29 20:00:46', 8, 8),
(101, 8, 8, '2025-03-29', 'Kang Reza', NULL, 'Ciater, Subang', NULL, NULL, 'uploads/1753794257_20250509_132411.jpg', 0, 'Penanaman 2 bungkus', 'completed', '2025-05-30', '2025-07-29 20:04:18', '2025-07-29 20:06:03', 8, 8),
(102, 8, 2, '2025-04-21', 'Pak Unem', NULL, 'Ciater, Subang', NULL, NULL, 'uploads/1753794873_20250620_152440.jpg', 0, 'Penanaman 1 bungkus', 'completed', '2025-07-04', '2025-07-29 20:14:35', '2025-07-29 20:17:05', 8, 8),
(103, 8, 6, '2025-05-15', 'Kang Elan', NULL, 'Ciater, Subang', NULL, NULL, 'uploads/1753795356_20250630_093543.jpg', 0, 'Penanaman 5 bungkus', 'completed', '2025-07-02', '2025-07-29 20:22:37', '2025-07-29 20:24:50', 8, 8),
(104, 8, 6, '2025-05-30', 'Kang Andri', NULL, 'Ciater, Subang', NULL, NULL, 'uploads/1753795610_20250609_093819.jpg', 0, 'Penanaman 2 bungkus', 'completed', '2025-07-04', '2025-07-29 20:26:51', '2025-07-29 20:28:19', 8, 8),
(105, 7, 1, '2025-02-22', 'Pak udin', NULL, 'Palasah', NULL, NULL, 'uploads/1753795670_IMG-20250729-WA0035.jpg', 0, NULL, 'completed', '2025-04-27', '2025-07-29 20:27:50', '2025-07-29 20:28:26', 7, 7),
(107, 8, 1, '2025-05-26', 'Kang Didi', NULL, 'Ciater, Subang', 1000, NULL, 'uploads/1753796794_20250619_152836.jpg', 0, 'Penanaman Sampel', 'completed', '2025-08-08', '2025-07-29 20:46:36', '2025-08-08 11:36:49', 8, 8),
(108, 8, 11, '2025-05-31', 'Pak Iwan', NULL, 'Ciater, Subang', 3500, NULL, 'uploads/1754390969_PhotoGrid_Plus_1754390916963.jpg', 0, 'Penanaman 1 bungkus', 'satisfactory', '2025-08-01', '2025-07-29 20:49:31', '2025-10-21 18:10:13', 8, 8),
(109, 7, 2, '2025-03-01', 'Mas iing', NULL, 'CikedungIndramayu', NULL, NULL, 'uploads/1753796977_IMG-20250506-WA0008.jpg', 0, NULL, 'completed', '2025-05-13', '2025-07-29 20:49:37', '2025-07-29 20:49:57', 7, 7),
(110, 8, 11, '2025-05-05', 'Pak H Ope', NULL, 'Bojong, Purwakarta', 1500, NULL, 'uploads/1754627787_PhotoGrid_Plus_1754563908235.jpg', 0, 'Penanaman 1 bungkus', 'unsatisfactory', '2025-08-07', '2025-07-29 21:06:29', '2025-10-21 18:08:40', 8, 8),
(111, 6, 9, '2025-06-28', 'Pak Kirman', '+62 853-2345-0215', 'Ds. Argamukti Kec. Argapura Kab. Majalengka', 1000, NULL, 'uploads/1755832486_IMG_1861.jpeg', 0, NULL, 'completed', '2025-08-22', '2025-07-30 12:04:52', '2025-12-05 21:20:45', 6, 6),
(112, 8, 11, '2025-05-25', 'Pak Kamang', NULL, 'Darangdan, Purwakarta', 1500, NULL, 'uploads/1754391047_PhotoGrid_Plus_1754391010486.jpg', 0, 'Penanaman Sampel', 'unsatisfactory', '2025-07-30', '2025-07-30 13:23:14', '2025-09-09 22:05:02', 8, 8),
(113, 5, 12, '2025-07-27', 'Mas erwan', NULL, 'Waled', 15750, NULL, 'uploads/1757944041_IMG20250826135754.jpg', 0, NULL, 'satisfactory', '2025-10-16', '2025-07-30 14:26:07', '2025-10-16 20:26:05', 5, 5),
(114, 8, 2, '2025-06-17', 'Pak Asnu', NULL, 'Bungursari, Purwakarta', 13500, NULL, 'uploads/1755666367_PhotoGrid_Plus_1755666081352.jpg', 0, NULL, 'completed', '2025-08-29', '2025-07-31 11:59:10', '2025-09-09 22:01:53', 8, 8),
(116, 6, 9, '2025-05-01', 'Pak Didi', NULL, 'Ds. Cisantana Kec. Cigugur Kab. Kuningan', 4500, NULL, 'uploads/1754030261_IMG_1297.jpeg', 0, NULL, 'completed', '2025-09-09', '2025-08-01 13:37:41', '2025-09-09 16:24:38', 6, 6),
(117, 7, 1, '2025-04-08', 'Pak aceng', NULL, 'Cipadung', NULL, NULL, 'uploads/1754063518_1000187163.jpg', 0, NULL, 'completed', '2025-06-14', '2025-08-01 22:49:07', '2025-08-01 23:04:44', 7, 7),
(119, 5, 4, '2025-08-06', 'PakAdi', NULL, 'Wanasaba kidul', 21000, NULL, 'uploads/1757943880_IMG20250906102039.jpg', 0, NULL, 'satisfactory', '2025-10-04', '2025-08-04 07:52:37', '2025-11-13 00:04:41', 5, 5),
(120, 6, 2, '2025-07-18', 'Pak Jaja', '+62 853-1688-5409', 'Ds. Sidamulya Kec. Jalaksana Kab. Kuningan', 1500, '-6.929596922538542,108.47356735806993', 'uploads/1759224184_IMG_0075.jpeg', 0, NULL, 'completed', '2025-09-30', '2025-08-04 09:41:17', '2025-10-10 10:36:15', 6, 6),
(121, 7, 11, '2025-07-31', 'Pak toto', NULL, 'Majasari ligung', 0, NULL, 'uploads/1754278555_1000480622.jpg', 1, NULL, 'not_yet_planted', NULL, '2025-08-04 10:35:56', NULL, 7, NULL),
(122, 6, 8, '2025-08-09', 'Pak Mamat', '+62 881-0224-61444', 'Ds. Sukadana Kec. Argapura Kab. Majalengka', 1500, '-6.903732901572764,108.33165317372143', 'uploads/1759804782_6eb4a222-d4c8-44f3-9c2a-35db9c08006f.jpeg', 0, NULL, 'completed', '2025-10-06', '2025-08-04 10:50:32', '2025-11-14 09:39:54', 6, 6),
(124, 7, 1, '2025-08-23', 'Pak udin', NULL, 'Majasuka', 3, NULL, 'uploads/1757298621_1000529148.jpg', 0, NULL, 'failed', '2025-10-10', '2025-08-05 20:35:32', '2025-10-10 11:44:06', 7, 7),
(125, 5, 3, '2025-08-04', 'Pak kurman', NULL, 'Waled Cirebon', 1400, NULL, 'uploads/1757944838_IMG20250826140200.jpg', 0, NULL, 'satisfactory', '2025-10-10', '2025-08-05 20:57:02', '2025-10-16 20:42:25', 5, 5),
(126, 5, 1, '2025-07-30', 'Haji bun', NULL, 'Weru, cirebon', 7000, NULL, 'uploads/1757943541_IMG20250909112913.jpg', 0, 'Penanaman benih Lilac 5 bungkus pembelian online karena stok dikios tidak ada', 'satisfactory', '2025-10-13', '2025-08-06 09:11:14', '2025-10-16 20:17:02', 5, 5),
(127, 6, 8, '2025-05-10', 'Pak Yuyu', '+62 812-2414-3472', 'Ds. Cipulus Kec. Cikijing Kab. Majalengka', 1500, '-6.965155220209947,108.38171424073286', 'uploads/1755827160_IMG_1854.jpeg', 0, 'Tercampur dengan gustavi', 'completed', '2025-09-09', '2025-08-06 09:11:24', '2025-09-09 16:22:01', 6, 6),
(128, 5, 1, '2025-07-24', 'Mang likun', NULL, 'Weru, cirebon', 5600, '-6.7276,108.4294885', 'uploads/1757943804_IMG20250909104838.jpg', 0, NULL, 'satisfactory', '2025-10-01', '2025-08-06 09:14:14', '2025-10-16 20:23:34', 5, 5),
(129, 7, 2, '2025-08-07', 'Pak eme', NULL, 'Panongan', 1, NULL, NULL, 0, 'Tanam 6pcs', 'failed', '2025-08-20', '2025-08-07 07:05:50', '2025-08-20 10:38:30', 7, 7),
(130, 7, 1, '2025-08-07', 'Pak gone', NULL, 'Majasuka', 3900, NULL, 'uploads/1759636084_1000564283.jpg', 0, 'Tanam 3 pcs', 'completed', '2025-10-15', '2025-08-07 07:26:21', '2025-10-15 20:38:02', 7, 7),
(131, 7, 2, '2025-08-07', 'Pak eme', NULL, 'Panongan', 1, NULL, NULL, 1, 'Tanam 10pcs', 'failed', '2025-08-20', '2025-08-07 07:27:03', '2025-08-20 10:37:32', 7, 7),
(132, 6, 6, '2025-07-24', 'Pak Mukit', '+62 812-8040-8991', 'Ds. Sindangbarang Kec. Jalaksana Kab. Kuningan', 7200, '-6.933875218230149,108.5171432436933', 'uploads/1756701287_IMG_2355.jpeg', 0, NULL, 'completed', '2025-09-09', '2025-08-07 08:41:43', '2025-09-09 16:18:48', 6, 6),
(133, 6, 2, '2025-07-16', 'Pak Sajidin', '+62 838-4163-0788', 'Ds. Timbang Kec. Cigandamekar Kab. Kuningan', 8400, '-6.880089877671726,108.52967695003899', 'uploads/1756887324_IMG_2361.jpeg', 0, NULL, 'completed', '2025-09-03', '2025-08-07 11:08:44', '2025-09-24 18:20:07', 6, 6),
(134, 6, 2, '2025-07-29', 'Pak Said', '0823 20711215', 'Ds. Timbang Kec. Cigandamekar Kab. Kuningan', 8400, NULL, 'uploads/1758712721_IMG_3077.jpeg', 0, NULL, 'completed', '2025-09-24', '2025-08-07 11:20:14', '2025-10-30 21:31:04', 6, 6),
(135, 8, 2, '2025-07-08', 'Kang Didi', NULL, 'Ciater, Subang', 2000, NULL, 'uploads/1755590311_PhotoGrid_Plus_1755590203770.jpg', 0, 'Penanaman untuk jadi pagar tanaman utama', 'completed', '2025-08-19', '2025-08-08 10:35:25', '2025-10-02 07:25:41', 8, 8),
(136, 5, 2, '2025-07-26', 'Pak warma', NULL, 'Sumber', 8, NULL, 'uploads/1757945087_IMG20250915160931.jpg', 0, NULL, 'satisfactory', '2025-09-26', '2025-08-10 23:14:31', '2025-10-16 20:38:10', 5, 5),
(137, 6, 8, '2025-07-09', 'Pak Saefudin', NULL, 'Ds. Sukamenak Kec. Bantarujeg Kab. Majalengka', 1500, '-6.936827788650972,108.26341057247895', 'uploads/1754885015_IMG_1487.jpeg', 0, NULL, 'completed', '2025-08-11', '2025-08-11 11:03:35', '2025-10-10 10:34:35', 6, 6),
(138, 6, 2, '2025-07-09', 'Pak Saefudin', NULL, 'Ds. Sukamenak Kec. Bantarujeg Kab. Majalengka', 800, '-6.936827788650972,108.26341057247895', 'uploads/1754885348_IMG_1489.jpeg', 0, NULL, 'completed', '2025-08-11', '2025-08-11 11:09:08', '2025-10-10 10:34:58', 6, 6),
(139, 8, 11, '2025-07-01', 'Kang Aji', NULL, 'Ciater, Subang', 1000, NULL, 'uploads/1759471134_PhotoGrid_Plus_1759471000673.jpg', 0, 'Penanaman 1 bungkus', 'completed', '2025-10-03', '2025-08-11 12:23:44', '2026-01-21 15:21:31', 8, 8),
(140, 7, 6, '2025-08-07', 'Pak tata', NULL, 'Karyamukti', 800, NULL, 'uploads/1756971836_1000524279.jpg', 0, NULL, 'completed', '2025-10-05', '2025-08-11 12:35:11', '2025-10-05 10:40:05', 7, 7),
(141, 8, 6, '2025-07-29', 'Pak Erwin', NULL, 'Ciater, Subang', 5500, NULL, 'uploads/1756188453_PhotoGrid_Plus_1756183529089.jpg', 0, NULL, 'satisfactory', '2025-08-26', '2025-08-12 10:53:12', '2025-10-21 18:08:00', 8, 8),
(142, 8, 11, '2025-08-19', 'Pak Jali', NULL, 'Ciater, Subang', 10000, NULL, 'uploads/1764135577_PhotoGrid_Plus_1764134869605.jpg', 1, NULL, 'satisfactory', '2025-11-26', '2025-08-12 14:09:30', '2025-11-26 12:39:37', 8, 8),
(143, 5, 1, '2025-08-20', 'Agus', NULL, 'Pabedilan', 7000, NULL, 'uploads/1757849193_Screenshot_2025-09-14-18-26-13-85_40deb401b9ffe8e1df2f1cc5ba480b12.jpg', 0, 'Proses pengawalan dan koordinasi atur jadwal tanam jagung Lilac dipabedilan', 'satisfactory', '2025-10-14', '2025-08-12 21:34:32', '2025-11-13 00:05:03', 5, 5),
(144, 8, 2, '2025-07-11', 'Pak Asnu', NULL, 'Bungursari, Purwakarta', 15000, '-6.4640722,107.4893577', 'uploads/1758512822_PhotoGrid_Plus_1758512746749.jpg', 0, NULL, 'completed', '2025-09-22', '2025-08-13 12:37:10', '2025-09-22 10:48:04', 8, 8),
(145, 5, 12, '2025-08-14', 'Pak haji waud', NULL, 'Pabedilan', 15750, NULL, 'uploads/1757945440_IMG20250819151225.jpg', 0, 'Tanaman tidak tumbuh optimal dikarenakan terendam air hujan 2 hari berturut-turut', 'satisfactory', '2025-09-29', '2025-08-15 07:30:49', '2025-11-13 00:00:39', 5, 5),
(146, 5, 12, '2025-08-22', 'Pak unawar', NULL, 'Pabuaran', 3600, NULL, 'uploads/1757944692_IMG-20250915-WA0068.jpg', 0, 'L7 di 2 tempat gagal tumbuh akibat terendam air hujan 2 hari berturut-rurut', 'unsatisfactory', '2025-09-04', '2025-08-15 07:33:19', '2025-10-16 20:43:29', 5, 5),
(147, 8, 11, '2025-08-05', 'Pak Iwan', NULL, 'Ciater, Subang', 1500, NULL, 'uploads/1756188390_20250826_123003.jpg', 0, NULL, 'satisfactory', '2025-08-26', '2025-08-15 15:43:51', '2025-10-21 18:08:20', 8, 8),
(148, 6, 11, '2025-08-01', 'Pak Erwin', '+62 813-3727-9877', 'Ds. Borogojol Kec. Lemahsugih Kab. Majalengka', 3700, NULL, 'uploads/1763088681_2a0fbc60-64e7-40dd-b04f-3751b4908263.jpeg', 0, NULL, 'completed', '2025-11-13', '2025-08-15 18:03:30', '2026-01-13 18:13:21', 6, 6),
(149, 7, 6, '2025-09-18', 'Pak adang', NULL, 'Kertajati', 4000, NULL, 'uploads/1758150540_1000542318.jpg', 1, 'Tanam 5 pcs', 'satisfactory', '2025-09-11', '2025-08-19 16:04:49', '2025-10-11 11:28:33', 7, 7),
(150, 7, 6, '2025-09-02', 'Pak asep', NULL, 'Maodin', 8000, NULL, 'uploads/1759325569_1000560030.jpg', 1, '10 pcs', 'satisfactory', '2025-10-01', '2025-08-19 16:05:38', '2025-10-01 20:32:58', 7, 7),
(151, 11, 8, '2025-08-19', 'Bah Ali (Penanggung Jawab Lahan 1Kang Bos Dani)', NULL, 'Titisan', 1800, '-6.8304608,107.1683572', 'uploads/1755600435_IMG_20250819_141222_736.jpg', 1, 'Monitoring perkembangan Tomat Nona 23 F1(±)45 Hst, Untuk Pertumbuhan Cukup bagus dan ada satu tanaman sudah terserang pythoptora dan bercak alternaria disandingin dengan kompetitor dari AURA SEED', 'not_yet_planted', NULL, '2025-08-19 17:47:15', '2025-08-19 17:51:16', 11, 11),
(152, 11, 11, '2025-08-19', 'Kang Dani Behom', NULL, 'Titisan', 2000, '-6.8304506,107.1683561', 'uploads/1755601289_IMG_20250819_141113_431.jpg', 1, 'Monitoring Shima (±) 59 Hst Untuk pertumbuhan lumayan memuaskan dan menunggu hasil buah, ketahanan virus lumayan toleran baru satu tanaman yang termonitor sudah terserang Gemini Virus', 'not_yet_planted', NULL, '2025-08-19 18:01:30', NULL, 11, NULL),
(153, 7, 6, '2025-08-24', 'Abah maun', NULL, 'Majasari', 1600, NULL, 'uploads/1757310392_1000529654.jpg', 1, NULL, 'unsatisfactory', '2025-10-05', '2025-08-20 11:58:34', '2025-10-05 10:35:53', 7, 7),
(154, 7, 1, '2025-08-10', 'Pak taspi', NULL, 'Cidenok', 5, NULL, 'uploads/1757408170_1000531041.jpg', 1, NULL, 'satisfactory', '2025-09-09', '2025-08-20 12:42:20', '2025-09-09 15:56:18', 7, 7),
(155, 8, 11, '2025-07-01', 'Pak Eka', NULL, 'Darangdan, Purwakarta', 500, NULL, 'uploads/1755749294_PhotoGrid_Plus_1755749221170.jpg', 0, NULL, 'unsatisfactory', '2025-08-21', '2025-08-21 11:08:14', '2025-10-21 18:07:42', 8, 8),
(156, 11, 6, '2025-08-21', 'A Dede', NULL, 'Bojongpicun', 1600, '-6.850405,107.2550867', 'uploads/1755761816_img_20250821_143617_833295665035155694.jpg', 0, 'Lavanta', 'completed', '2025-08-21', '2025-08-21 14:36:57', '2025-10-02 12:36:52', 11, 11),
(157, 8, 11, '2025-08-12', 'Pak Yana', NULL, 'Wanayasa, Purwakarta', 1000, NULL, 'uploads/1755768619_PhotoGrid_Plus_1755768366828.jpg', 0, NULL, 'completed', '2025-08-21', '2025-08-21 16:30:19', '2026-01-21 15:22:37', 8, 8),
(158, 6, 9, '2025-07-12', 'Pak Kirman', '+62 853-2345-0215', 'Ds. Argamukti Kec. Argapura Kab. Majalengka', 1700, '-6.906674592129402,108.360220729281', 'uploads/1757590199_IMG_2602.jpeg', 0, NULL, 'completed', '2025-09-11', '2025-08-22 10:18:01', '2025-12-05 21:23:09', 6, 6),
(159, 8, 6, '2025-08-16', 'Kang Aji', NULL, 'Ciater, Subang', 1500, NULL, 'uploads/1758877620_PhotoGrid_Plus_1758875746782.jpg', 0, NULL, 'satisfactory', '2025-09-26', '2025-08-22 16:02:24', '2025-10-21 18:05:57', 8, 8),
(160, 11, 11, '2025-08-27', 'Bos Dankus', NULL, 'Kebonpeuteuy', 4000, '-6.8304621,107.1683609', 'uploads/1756254163_IMG-20250822-WA0013.jpg', 1, NULL, 'satisfactory', '2025-07-29', '2025-08-27 07:22:43', '2025-08-27 07:24:12', 11, 11),
(161, 6, 2, '2025-07-19', 'Pak Juju', NULL, 'Ds. Sukamukti Kec. Jalaksana Kab. Kuningan', 2975, NULL, 'uploads/1758531672_IMG_2973.jpeg', 0, NULL, 'completed', '2025-09-22', '2025-08-27 09:31:10', '2025-10-17 21:17:28', 6, 6),
(162, 6, 2, '2025-07-10', 'Pak Momon', NULL, 'Ds. Sukamukti Kec. Jalaksana Kab. Kuningan', 2975, NULL, 'uploads/1759223337_IMG_0062.jpeg', 0, NULL, 'completed', '2025-09-30', '2025-08-27 09:33:11', '2025-10-10 10:30:53', 6, 6),
(163, 6, 2, '2025-08-03', 'Pak Holil', NULL, 'Ds. Sukamukti Kec. Jalaksana Kab. Kuningan', 2750, NULL, 'uploads/1760710463_IMG_0400.jpeg', 0, NULL, 'completed', '2025-10-17', '2025-08-27 09:38:38', '2025-10-24 07:53:03', 6, 6),
(164, 6, 2, '2025-07-26', 'Pak Sartum', NULL, 'Ds. Sukamukti Kec. Jalaksana Kab. Kuningan', 2975, NULL, 'uploads/1758531415_IMG_2972.jpeg', 0, NULL, 'completed', '2025-09-22', '2025-08-27 09:44:19', '2025-10-17 21:18:34', 6, 6),
(165, 6, 2, '2025-08-09', 'Pak Kosta', NULL, 'Ds. Sukamukti Kec. Jalaksana Kab. Kuningan', 2975, '-6.9324033,108.4566131', 'uploads/1760710351_IMG_0399.jpeg', 0, NULL, 'completed', '2025-10-17', '2025-08-27 09:48:20', '2025-10-30 21:31:48', 6, 6),
(166, 6, 2, '2025-06-20', 'Pak Sardi', NULL, 'Ds. Sukamukti Kec. Jalaksana Kab. Kuningan', 4465, NULL, 'uploads/1757646611_IMG_2627.jpeg', 0, NULL, 'completed', '2025-09-12', '2025-08-27 09:53:02', '2025-09-22 15:58:37', 6, 6),
(167, 8, 8, '2025-08-15', 'Pak Idin', NULL, 'Serangpanjang, Subang', 3080, NULL, 'uploads/1756383669_PhotoGrid_Plus_1756383646691.jpg', 0, 'Persemaian', 'not_yet_planted', NULL, '2025-08-28 19:21:09', '2025-10-21 18:09:00', 8, 8),
(168, 6, 8, '2025-09-16', 'Pak Winanta', '+62 882-2233-9416', 'Ds. Cibunut Kec. Argapura Kab. Majalengka', 2975, NULL, 'uploads/1764944323_IMG_1429.jpeg', 0, NULL, 'completed', '2025-11-20', '2025-08-29 19:14:37', '2025-12-25 20:05:16', 6, 6),
(169, 6, 9, '2025-08-29', 'Pak Dedi', '+62 812-2327-0373', 'Ds. Sukadana Kec. Argapura Kab. Majalengka', 1000, NULL, 'uploads/1756469771_9ddb54d4-d5e4-4b16-bd45-b8d65220050a.jpeg', 0, NULL, 'not_yet_planted', NULL, '2025-08-29 19:16:11', '2025-12-05 21:22:29', 6, 6),
(170, 7, 1, '2025-08-06', 'Pak taspi', NULL, 'Ligung', 6500, NULL, 'uploads/1759636056_1000564284.jpg', 0, NULL, 'completed', '2025-10-15', '2025-08-30 10:29:53', '2025-10-15 20:38:40', 7, 7),
(171, 7, 1, '2025-08-06', 'Pak meme', NULL, 'Majasuka', 2600, NULL, 'uploads/1759326817_1000560034.jpg', 1, NULL, 'satisfactory', '2025-10-01', '2025-08-30 11:08:19', '2025-10-01 20:53:47', 7, 7),
(172, 7, 4, '2025-08-21', 'Pak rifai', NULL, 'Balida', 3000, NULL, 'uploads/1756527026_1000517290.jpg', 0, NULL, 'not_yet_planted', NULL, '2025-08-30 11:10:26', NULL, 7, NULL),
(173, 7, 1, '2025-08-08', 'Pak heri', NULL, 'Palasah', 2600, NULL, 'uploads/1759636147_1000558796.jpg', 0, NULL, 'completed', '2025-10-15', '2025-08-30 11:14:53', '2025-10-15 20:39:12', 7, 7),
(174, 6, 8, '2025-05-26', 'Pak Imam', '+62 812-1095-3001', 'Ds. Argalingga Kec. Argapura Kab. Majalengka', 1000, NULL, 'uploads/1756710972_IMG_2091.jpeg', 0, 'Dijadikan FT', 'completed', '2025-09-01', '2025-09-01 14:16:12', '2025-10-10 10:32:10', 6, 6),
(175, 6, 4, '2025-08-14', 'Pak Diran', '+62 812-2215-1906', 'Ds. Sembawa Kec. Jalaksana Kab. Kuningan', 1785, NULL, 'uploads/1761267405_IMG_0494.jpeg', 0, NULL, 'completed', '2025-10-23', '2025-09-03 15:06:42', '2025-11-14 09:37:13', 6, 6),
(176, 6, 2, '2025-08-27', 'Pak Salam', NULL, 'Ds. Jalaksana Kec. Jalaksana Kab. Kuningan', 2975, NULL, 'uploads/1756886956_IMG_2384.jpeg', 0, NULL, 'completed', '2025-09-03', '2025-09-03 15:09:17', '2025-12-05 21:22:06', 6, 6),
(177, 7, 6, '2025-09-01', 'Reno', NULL, 'Kertajati', 7, NULL, 'uploads/1759635111_1000560036.jpg', 1, NULL, 'satisfactory', '2025-10-05', '2025-09-03 16:31:41', '2025-10-05 10:32:05', 7, 7),
(178, 7, 6, '2025-09-09', 'Pak ibun', NULL, 'Banggala', 5, NULL, 'uploads/1759325533_1000560029.jpg', 1, NULL, 'satisfactory', '2025-10-01', '2025-09-03 16:40:03', '2025-10-01 20:32:21', 7, 7),
(179, 7, 6, '2025-08-30', 'Pak yana', NULL, 'Kertajati', 5, NULL, 'uploads/1758150811_1000542322.jpg', 1, NULL, 'satisfactory', '2025-09-18', '2025-09-03 16:40:51', '2025-09-18 06:13:40', 7, 7),
(180, 5, 1, '2025-08-22', 'Pak sihab', '0895-3200-14447', 'Karangsari,Plumbon cirebon', 42000, '-6.6913417,108.4993834', 'uploads/1757945957_IMG-20250915-WA0073.jpg', 0, 'Tanam jagung Lilac 30 bungkus disebar ke 3 titik dipetani binannya', 'satisfactory', '2025-11-02', '2025-09-04 20:00:55', '2025-11-12 23:59:46', 5, 5),
(181, 8, 9, '2025-10-01', 'Pak Mantri Andi', NULL, 'Ciater, Subang', 1000, NULL, 'uploads/1764136061_PhotoGrid_Plus_1764135137568.jpg', 1, NULL, 'satisfactory', '2025-11-26', '2025-09-09 10:05:12', '2025-11-26 12:47:41', 8, 8),
(182, 8, 8, '2025-08-30', 'Pak Dedi', NULL, 'Sagalaherang, Subang', 2500, NULL, 'uploads/1758009473_20250916_145411.jpg', 0, NULL, 'satisfactory', '2025-09-16', '2025-09-09 14:06:46', '2025-10-21 18:07:16', 8, 8),
(183, 6, 2, '2025-09-06', 'Pak Momon', '+62 877-0923-7195', 'Ds. Sukamukti Kec. Jalaksana Kab. Kuningan', 2975, NULL, 'uploads/1762214010_IMG_0993.jpeg', 0, NULL, 'completed', '2025-11-03', '2025-09-09 16:30:38', '2025-12-25 20:10:55', 6, 6),
(184, 5, 1, '2025-08-25', 'Pak suparno', NULL, 'Karangsari', 11600, NULL, 'uploads/1757942427_IMG-20250915-WA0066.jpg', 0, 'Penanaman jagung Lilac 8 bungkus', 'satisfactory', '2025-10-24', '2025-09-09 19:39:18', '2025-11-13 00:20:47', 5, 5),
(185, 5, 1, '2025-08-30', 'Gandi', NULL, 'Weru', 14500, NULL, 'uploads/1762966658_IMG20251112091143.jpg', 0, 'Penanaman jagung Lilac10 bungkus', 'satisfactory', '2025-11-12', '2025-09-09 19:41:44', '2025-11-12 23:57:38', 5, 5),
(186, 5, 1, '2025-08-25', 'Binaan mang likun', NULL, 'Megu', 5800, NULL, 'uploads/1762967053_IMG20251104133042.jpg', 0, 'Penanaman jagung madu 2 bungkus dan Lilac 7 bungkus dimegu', 'satisfactory', '2025-11-05', '2025-09-09 19:45:32', '2025-11-13 00:04:13', 5, 5),
(187, 7, 1, '2025-07-05', 'Pak Rus', NULL, 'Majasuka', 1, NULL, 'uploads/1757424838_1000529291.jpg', 1, NULL, 'satisfactory', '2025-09-10', '2025-09-09 20:33:58', '2025-09-10 05:16:30', 7, 7),
(188, 11, 11, '2025-05-31', 'Ade Janna', NULL, 'Lemanduhur', 2000, '-6.8304308,107.1683662', 'uploads/1757502007_IMG_20250718_112229_150.jpg', 1, 'Pertumbuhan dan Ketahanan masih cukup baik', 'not_yet_planted', NULL, '2025-09-10 17:57:55', '2025-09-10 18:00:08', 11, 11),
(189, 17, 6, '2025-09-10', 'Bos Kacung', '0987324', 'Wanaraja', 1600, NULL, 'uploads/1757508928_AI_Artist-removebg-preview.png', 1, NULL, 'satisfactory', '2025-09-10', '2025-09-10 19:55:28', '2025-09-10 19:56:11', 17, 17),
(190, 8, 2, '2025-08-02', 'Pak H Kasim', NULL, 'Bungursari, Purwakarta', 22000, '-6.4638288,107.4897721', 'uploads/1758527041_PhotoGrid_Plus_1758526680736.jpg', 0, NULL, 'satisfactory', '2025-09-22', '2025-09-11 13:35:59', '2025-10-21 18:06:31', 8, 8),
(191, 8, 2, '2025-08-06', 'Pak H Kasim', NULL, 'Bungursari, Purwakarta', 36000, '-6.4641064,107.4893807', 'uploads/1758527002_PhotoGrid_Plus_1758526718691.jpg', 0, NULL, 'satisfactory', '2025-09-22', '2025-09-11 13:38:27', '2025-10-21 18:06:48', 8, 8),
(192, 8, 2, '2025-08-02', 'Pak Uday', NULL, 'Tanjungsiang, Subang', 7000, NULL, 'uploads/1757652493_PhotoGrid_Plus_1757652401372.jpg', 0, NULL, 'satisfactory', '2025-09-12', '2025-09-12 11:48:13', '2025-11-14 12:21:41', 8, 8),
(193, 8, 8, '2025-09-02', 'Pak Uday', NULL, 'Tanjungsiang, Subang', 1000, NULL, 'uploads/1758252599_PhotoGrid_Plus_1758252526200.jpg', 0, NULL, 'completed', '2025-09-19', '2025-09-12 11:49:01', '2026-01-21 15:22:07', 8, 8),
(194, 6, 2, '2025-08-23', 'Pak Udin', '+62 852-2112-0445', 'Ds. Sukamukti Kec. Jalaksana Kab. Kuningan', 1000, NULL, 'uploads/1762214256_9639c4e1-56f1-4726-9d74-85de9c9c907e.jpeg', 0, NULL, 'completed', '2025-11-03', '2025-09-12 22:53:41', '2025-12-05 21:26:55', 6, 6),
(195, 6, 2, '2025-06-20', 'Pak Udin', '+62 852-2112-0445', 'Ds. Sukamukti Kec. Jalaksana Kab. Kuningan', 1500, NULL, 'uploads/1757692962_IMG_2641.jpeg', 0, NULL, 'completed', '2025-09-22', '2025-09-12 23:02:42', '2025-09-22 15:53:36', 6, 6),
(196, 7, 1, '2025-09-15', 'A emen', NULL, 'Cijurey', 5, NULL, 'uploads/1762948975_1000615265.jpg', 0, 'Tanam 5pcs', 'completed', '2025-12-05', '2025-09-15 18:30:21', '2025-12-05 21:16:58', 7, 7),
(197, 7, 6, '2025-09-18', 'Pak dede', NULL, 'Karang anyar', 20, NULL, 'uploads/1761270048_1000585533.jpg', 1, '2iner', 'satisfactory', '2025-10-15', '2025-09-15 18:31:23', '2025-10-24 08:40:49', 7, 7),
(198, 21, 17, '2025-07-30', 'Dudi', NULL, 'Juntinyuat', 1000, NULL, 'uploads/1757948947_1000110961.jpg', 1, 'TO 4648\r\nNona 23 F1\r\nServo F1\r\nCorona 402\r\nComodor F1', 'satisfactory', '2025-09-15', '2025-09-15 22:09:07', '2025-09-15 22:12:36', 21, 21),
(199, 21, 17, '2025-07-31', 'Alo', NULL, 'Banyuresmi, Garut', 1000, NULL, 'uploads/1757949319_1000110958.jpg', 1, NULL, 'satisfactory', '2025-09-15', '2025-09-15 22:15:19', '2025-09-15 22:17:19', 21, 21),
(200, 6, 6, '2025-09-15', 'Pak Dira', NULL, 'Ds. Gunung Karung Kec. Luragung Kab. Kuningan', 6120, NULL, 'uploads/1760503992_IMG_0367.jpeg', 0, NULL, 'completed', '2025-10-15', '2025-09-16 11:01:40', '2025-11-14 09:38:54', 6, 6),
(201, 6, 2, '2025-09-11', 'Pak Ahyadi', '+62 831-6635-1112', 'Ds. Gandasoli Kec. Kramatmulya Kab. Kuningan', 5950, NULL, NULL, 0, NULL, 'not_yet_planted', NULL, '2025-09-16 11:03:58', '2025-12-05 21:19:32', 6, 6),
(202, 8, 8, '2025-09-01', 'Pak Hidayat', NULL, 'Kiarapedes, Purwakarta', 900, NULL, 'uploads/1757998509_PhotoGrid_Plus_1757996824425.jpg', 0, NULL, 'satisfactory', '2025-09-16', '2025-09-16 11:55:09', '2025-11-26 12:57:39', 8, 8),
(203, 8, 6, '2025-08-19', 'Kang Wawan', NULL, 'Serangpanjang, Subang', 2300, NULL, 'uploads/1759470896_PhotoGrid_Plus_1759463459291.jpg', 0, NULL, 'satisfactory', '2025-10-03', '2025-09-16 14:03:33', '2025-10-21 18:05:43', 8, 8),
(204, 5, 1, '2025-09-16', 'Pak h.opik', NULL, 'Gebang', 7, NULL, 'uploads/1758845342_IMG20250924164930.jpg', 0, 'Penanaman Lilac dibinaan pak haji opik disebar diwilayah gebang', 'satisfactory', '2025-10-20', '2025-09-16 17:36:37', '2025-11-28 10:40:54', 5, 5),
(205, 7, 1, '2025-09-25', 'Pak anton', NULL, 'Karyamukti', 8, NULL, 'uploads/1759635439_1000564269.jpg', 0, NULL, 'completed', '2025-12-05', '2025-09-17 09:02:11', '2025-12-05 21:16:27', 7, 7),
(206, 7, 1, '2025-09-11', 'Pak omo', NULL, 'Majasuka', 2, NULL, 'uploads/1762214141_1000602611.jpg', 0, NULL, 'satisfactory', '2025-11-04', '2025-09-17 09:40:10', '2026-01-15 20:00:40', 7, 7),
(207, 11, 2, '2025-11-14', 'Pa Ade', NULL, 'Cikancana', 17000, '-6.8304513,107.1683509', 'uploads/1766099890_IMG_20251203_115713_096.jpg', 1, 'Madu59 penanaman 3-4 box di 3 lahan berbeda', 'completed', '2025-09-01', '2025-09-18 08:12:14', '2025-12-19 06:18:11', 11, 11),
(208, 6, 8, '2025-08-05', 'Pak Rusdiana', NULL, 'Ds. Cisantana Kec. Cigugur Kab. Kuningan', 1200, NULL, 'uploads/1762218172_b397927d-ff7d-4ef4-82ea-5d3579f3f20b.jpeg', 0, NULL, 'completed', '2025-10-31', '2025-09-19 20:42:43', '2025-11-14 09:40:24', 6, 6),
(209, 6, 9, '2025-08-12', 'Pak Rusdiana', NULL, 'Ds. Cisantana Kec. Cigugur Kab. Kuningan', 1400, '-6.9474333,108.4445867', 'uploads/1762218070_e9611f7a-34c7-4714-9d05-135f31d6b4c9.jpeg', 0, NULL, 'completed', '2025-10-31', '2025-09-19 20:46:54', '2025-12-05 21:27:55', 6, 6),
(210, 6, 8, '2025-08-08', 'Pak Jeri', '+62 851-5054-2363', 'Ds. Cisantana Kec. Cigugur Kab. Kuningan', 500, NULL, 'uploads/1762215234_IMG_0825.jpeg', 0, NULL, 'completed', '2025-10-31', '2025-09-19 20:49:03', '2025-12-05 21:29:27', 6, 6),
(211, 6, 8, '2025-09-19', 'Pak Rasna', '+62 852-2472-8173', 'Ds. Sidamulya Kec. Jalaksana Kab. Kuningan', 2975, NULL, 'uploads/1762213508_IMG_0998.jpeg', 0, NULL, 'completed', '2025-11-03', '2025-09-22 16:06:46', '2026-01-13 18:11:48', 6, 6),
(212, 6, 3, '2025-09-22', 'Pak Diran', '+62 812-2215-1906', 'Ds. Sembawa Kec. Jalaksana Kab. Kuningan', 2975, NULL, 'uploads/1761267311_IMG_0495.jpeg', 0, NULL, 'completed', '2025-10-23', '2025-09-22 16:10:36', '2026-01-13 18:08:47', 6, 6),
(213, 6, 2, '2025-09-14', 'Pak Udin', NULL, 'Ds. Sidamulya Kec. Jalaksana Kab. Kuningan', 2975, NULL, 'uploads/1764142770_IMG_1644.jpeg', 0, NULL, 'completed', '2025-11-26', '2025-09-22 16:14:21', '2025-12-25 20:07:16', 6, 6),
(214, 5, 2, '2025-09-24', 'Pak Adi', NULL, 'Wanasaba belakang bengkel', 4, NULL, 'uploads/1762966276_IMG20251108141157.jpg', 0, NULL, 'satisfactory', '2025-11-12', '2025-09-23 20:26:44', '2026-01-15 20:18:59', 5, 5),
(215, 5, 1, '2025-09-24', 'Pak adi', NULL, 'Wanasaba belakang bengkel', 3, NULL, 'uploads/1762966145_IMG20251108134710.jpg', 0, NULL, 'satisfactory', '2025-11-12', '2025-09-23 20:29:04', '2026-01-12 16:04:54', 5, 5),
(216, 5, 2, '2025-09-13', 'Bu warlim', NULL, 'Getrokmoyan', 3, NULL, 'uploads/1761271274_IMG20251017104117.jpg', 0, NULL, 'satisfactory', '2025-11-26', '2025-09-23 20:38:19', '2025-11-28 10:40:13', 5, 5),
(217, 5, 2, '2025-10-10', 'Pak adi', NULL, 'Perumahan cempaka arum', 20, NULL, 'uploads/1760622827_IMG20251010092119.jpg', 0, NULL, 'satisfactory', '2025-11-25', '2025-09-23 20:50:53', '2026-01-12 16:01:11', 5, 5),
(218, 5, 1, '2025-10-08', 'Pak Opik pabuaran', NULL, 'Pabuaran', 8, NULL, 'uploads/1761868323_IMG20251029100302.jpg', 0, 'Ambil benih 20 pcs namun diseting per hari tanam 5-10 pcs', 'satisfactory', '2025-10-29', '2025-09-23 21:05:37', '2026-01-12 16:06:20', 5, 5),
(219, 6, 5, '2025-09-14', 'Pak Diran', '+62 812-2215-1906', 'Ds. Sembawa Kec. Jalaksana Kab. Kuningan', 4000, NULL, 'uploads/1760534492_e6319d5b-c2f7-4222-a804-e0507af7226a.jpeg', 0, NULL, 'completed', '2025-10-15', '2025-09-24 18:14:09', '2025-11-14 09:38:10', 6, 6),
(220, 7, 1, '2025-09-16', 'PakAnton', NULL, 'Panyingkiran', 7, NULL, 'uploads/1762948859_1000615266.jpg', 0, NULL, 'completed', '2025-12-05', '2025-09-26 06:51:08', '2025-12-05 21:17:28', 7, 7),
(221, 5, 2, '2025-09-24', 'Pak nana', NULL, 'Jatirenggang', 5, NULL, 'uploads/1762967347_IMG20251031135014.jpg', 0, 'Penanaman jagung reva 2 pcs, madu 5 pcs dan Lilac 1 pcs', 'satisfactory', '2025-10-31', '2025-09-26 07:02:04', '2026-01-12 16:05:21', 5, 5),
(222, 5, 2, '2025-10-17', 'Pak kamali', NULL, 'Sawah gede', 10, NULL, 'uploads/1764300255_IMG20251125123120.jpg', 0, NULL, 'satisfactory', '2025-11-28', '2025-09-26 07:03:33', '2026-01-12 16:04:39', 5, 5),
(223, 8, 8, '2025-09-11', 'Kang Sandy', NULL, 'Cijolang, Ciater Subang', 1700, NULL, 'uploads/1758856531_IMG-20250926-WA0004.jpg', 0, NULL, 'satisfactory', '2025-09-26', '2025-09-26 10:15:31', '2025-10-21 18:06:17', 8, 8),
(224, 8, 8, '2025-10-17', 'Pak Rosidin', NULL, 'Ciater, Subang', 3000, NULL, 'uploads/1761889269_PhotoGrid_Plus_1761888926808.jpg', 0, NULL, 'completed', '2025-10-31', '2025-09-26 11:26:00', '2026-01-21 15:20:42', 8, 8),
(225, 8, 2, '2025-09-22', 'Kang Ujang', NULL, 'Ciater, Subang', 15000, NULL, 'uploads/1764135257_PhotoGrid_Plus_1764134720943.jpg', 0, NULL, 'completed', '2025-11-26', '2025-09-26 14:52:28', '2026-01-21 15:18:33', 8, 8),
(226, 8, 9, '2025-10-10', 'Kang Ujang', NULL, 'Ciater, Subang', 5000, NULL, 'uploads/1764135438_PhotoGrid_Plus_1764134778373.jpg', 0, NULL, 'completed', '2025-11-26', '2025-09-26 14:55:55', '2026-01-21 15:17:01', 8, 8),
(227, 16, 13, '2025-09-29', 'H erik', '+62823-2171-5175', 'Samarang garut', 100, NULL, 'uploads/1759155426_IMG_0378.jpeg', 1, 'Tanaman saat pindah tanam terlalu besar, dan media persemain keras setrenya sangat tinggi waktu pindah tanam', 'not_yet_planted', NULL, '2025-09-29 21:17:07', NULL, 16, NULL),
(228, 16, 6, '2025-09-29', 'Ujang', '+62831-7568-5648', 'Samarang', 550, NULL, 'uploads/1759155702_IMG_0380.jpeg', 1, 'Waktu tanaman sudah tumbuh terkena sarengan ulat ranah tadi banyak lubang tanam kosong.', 'satisfactory', '2025-09-29', '2025-09-29 21:21:44', '2025-09-29 21:24:50', 16, 16),
(229, 16, 9, '2025-09-29', 'Kekey', '+62852-2365-7088', 'Toblong pasirwangi', 500, NULL, 'uploads/1759156669_IMG_0279.jpeg', 1, 'Tumpang sari dengan keriting', 'not_yet_planted', NULL, '2025-09-29 21:37:50', NULL, 16, NULL),
(230, 6, 2, '2025-08-15', 'Pak Kodir', NULL, 'Ds. Sukamukti Kec. Jalaksana Kab. Kuningan', 2975, NULL, 'uploads/1762214336_IMG_0988.jpeg', 0, NULL, 'completed', '2025-11-03', '2025-09-30 16:13:30', '2025-12-05 21:30:40', 6, 6),
(231, 15, 2, '2025-08-10', 'Dani', NULL, 'GadingTutuka', 70000, NULL, 'uploads/1759380657_IMG_20251002_094637.jpg', 1, 'Umur 55 hst , performa tanaman baik', 'satisfactory', '2025-10-02', '2025-10-02 11:50:58', '2025-10-02 15:43:20', 15, 15),
(232, 7, 1, '2025-09-11', 'Pak udin', NULL, 'Majasari', 3, NULL, 'uploads/1762214194_1000602612.jpg', 0, NULL, 'completed', '2025-12-05', '2025-10-03 07:20:25', '2025-12-05 21:18:21', 7, 7),
(233, 6, 2, '2025-08-19', 'Pak Juhani', NULL, 'Ds. Pajambon Kec. Kramatmulya Kab. Kuningan', 2975, NULL, 'uploads/1762214654_IMG_0981.jpeg', 0, NULL, 'completed', '2025-11-03', '2025-10-03 16:09:56', '2025-12-05 21:30:02', 6, 6);
INSERT INTO `demo_plots` (`id`, `user_id`, `product_id`, `plant_date`, `owner_name`, `owner_phone`, `field_location`, `population`, `latlong`, `image_path`, `active`, `notes`, `plant_status`, `last_visit`, `created_datetime`, `updated_datetime`, `created_by_uid`, `updated_by_uid`) VALUES
(234, 6, 2, '2025-09-13', 'Pak Abidin', NULL, 'Ds. Pajambon Kec. Kramatmulya Kab. Kuningan', 2975, NULL, 'uploads/1759482698_IMG_0150.jpeg', 0, NULL, 'completed', '2025-10-03', '2025-10-03 16:11:38', '2025-10-30 21:29:51', 6, 6),
(235, 6, 1, '2025-08-12', 'Pak Jumhari', NULL, 'Ds. Pajambon Kec. Kramatmulya Kab. Kuningan', 500, NULL, 'uploads/1759482818_IMG_0155.jpeg', 0, NULL, 'completed', '2025-10-03', '2025-10-03 16:13:38', '2025-12-05 21:24:08', 6, 6),
(236, 6, 2, '2025-08-14', 'Pak Sakim', NULL, 'Ds. Gandasoli Kec. Kramatmulya Kab. Kuningan', 5950, NULL, 'uploads/1762213251_IMG_1006.jpeg', 0, NULL, 'completed', '2025-11-03', '2025-10-03 16:15:36', '2025-12-05 21:26:09', 6, 6),
(237, 7, 1, '2025-10-01', 'Ibu iyet', NULL, 'Majasuka', 20, NULL, 'uploads/1759635873_1000551558.jpg', 1, NULL, 'satisfactory', '2025-10-05', '2025-10-05 10:43:08', '2025-10-05 10:44:48', 7, 7),
(238, 7, 2, '2025-10-06', 'Pak roni', NULL, 'Mekarjaya kertajati', 20, NULL, 'uploads/1759804714_1000566686.jpg', 0, NULL, 'failed', '2025-11-19', '2025-10-07 09:38:34', '2025-11-19 08:10:55', 7, 7),
(239, 6, 8, '2025-09-01', 'Pak Imam', '+62 812-1095-3001', 'Ds. Argalingga Kec. Argapura Kab. Majalengka', 1000, NULL, 'uploads/1759805508_62da1959-c442-4701-b80a-f42d33968714.jpeg', 0, NULL, 'completed', '2025-10-07', '2025-10-07 09:51:48', '2025-12-25 20:09:08', 6, 6),
(240, 6, 5, '2025-09-22', 'Pak Saqib', '+62 838-7574-7837', 'Ds. Pancalang Kec. Pancalang Kab. Kuningan', 800, NULL, 'uploads/1759805618_IMG_0216.jpeg', 0, NULL, 'completed', '2025-10-07', '2025-10-07 09:53:39', '2025-12-05 21:24:46', 6, 6),
(241, 6, 8, '2025-09-12', 'Pak Wawan', '+62 813-1254-5711', 'Ds. Cipulus Kec. Cikijing Kab. Majalengka', 4462, NULL, 'uploads/1764944062_IMG_1564.jpeg', 0, NULL, 'completed', '2025-12-03', '2025-10-09 08:26:54', '2025-12-25 20:05:58', 6, 6),
(242, 7, 2, '2025-10-02', 'Mas iing', NULL, 'JatisuraIndramayu', 20, NULL, 'uploads/1762214241_1000602614.jpg', 0, NULL, 'failed', '2025-11-19', '2025-10-11 11:27:00', '2025-11-19 08:09:20', 7, 7),
(243, 6, 8, '2025-10-04', 'Pak Jaja', '+62 853-1688-5409', 'Ds. Sidamulya Kec. Jalaksana Kab. Kuningan', 1500, NULL, 'uploads/1762213402_ae0484c9-3996-44df-bd8b-0718bbe6ba81.jpeg', 0, NULL, 'completed', '2025-11-03', '2025-10-14 15:08:41', '2026-01-13 18:10:54', 6, 6),
(244, 6, 2, '2025-08-10', 'Pak Iwan', NULL, 'Ds. Gandasoli Kec. Jalaksana Kab. Kuningan', 1500, NULL, 'uploads/1762212870_IMG_1011.jpeg', 0, NULL, 'completed', '2025-11-03', '2025-10-14 15:15:59', '2025-12-05 21:25:33', 6, 6),
(245, 7, 2, '2025-10-04', 'H.wadi', NULL, 'SitubolangIndramayu', 25, NULL, 'uploads/1760592567_1000578903.jpg', 0, NULL, 'failed', '2025-11-19', '2025-10-15 20:44:29', '2025-11-19 08:10:07', 7, 7),
(246, 7, 10, '2025-10-17', 'Pak darma', NULL, 'Maodin kertajati', 12, NULL, NULL, 1, NULL, 'not_yet_planted', NULL, '2025-10-15 20:49:22', NULL, 7, NULL),
(247, 7, 7, '2025-10-17', 'Pak darma', NULL, 'Maodin kertajati', 500, NULL, NULL, 1, NULL, 'not_yet_planted', NULL, '2025-10-15 20:49:53', NULL, 7, NULL),
(248, 7, 6, '2025-10-12', 'Pak yanto', NULL, 'Jaha palasah', 10, NULL, 'uploads/1766669115_1000669850.jpg', 1, NULL, 'satisfactory', '2025-12-25', '2025-10-15 20:51:50', '2025-12-25 20:25:15', 7, 7),
(249, 5, 2, '2025-10-17', 'Pak warma', NULL, 'Sawah gede sumber', 7, NULL, 'uploads/1760623018_IMG20251014163056.jpg', 0, 'Penanaman jagung madu 7pcs dan Lilac 3pcs', 'satisfactory', '2025-11-28', '2025-10-16 20:56:58', '2026-01-12 16:00:54', 5, 5),
(250, 5, 2, '2025-10-11', 'Rojai', NULL, 'Depok plumbon', 10, NULL, 'uploads/1764301017_IMG20251125140540.jpg', 0, NULL, 'satisfactory', '2025-11-28', '2025-10-16 20:58:44', '2026-01-12 16:03:56', 5, 5),
(251, 5, 2, '2025-10-20', 'Mas hadi', NULL, 'Weru', 4, NULL, 'uploads/1760623262_IMG20251014095839.jpg', 0, 'Penanaman jagung madu 2 pcs dan jagung Reva 2 pcs', 'satisfactory', '2025-12-03', '2025-10-16 21:01:02', '2026-01-12 16:01:37', 5, 5),
(252, 5, 4, '2025-08-18', 'Pak juned', NULL, 'Cibogo waled', 2, NULL, 'uploads/1760623650_IMG20251013134126.jpg', 0, 'Penanaman jagung reva', 'satisfactory', '2025-10-24', '2025-10-16 21:07:30', '2025-11-13 00:20:27', 5, 5),
(253, 5, 1, '2025-10-16', 'Rodiin', NULL, 'Plered,Cirebon', 10, NULL, 'uploads/1762966487_IMG20251110141531.jpg', 0, 'Persiapan penanaman jagung lilac. Progres saat ini sedang persiapan olah lahan', 'satisfactory', '2025-12-20', '2025-10-16 21:11:32', '2026-01-12 15:59:30', 5, 5),
(254, 6, 2, '2025-08-23', 'Pak Rusdi', NULL, 'Ds. Sukamukti Kec. Jalaksana Kab. Kuningan', 4462, NULL, 'uploads/1762214095_IMG_0991.jpeg', 0, NULL, 'completed', '2025-11-03', '2025-10-17 21:10:09', '2025-12-05 21:31:22', 6, 6),
(255, 8, 2, '2025-10-09', 'Pak Ananto', NULL, 'Darangdan, Purwakarta', 42000, '-6.6743481,107.4222241', 'uploads/1763695249_20251121_095608.jpg', 0, NULL, 'completed', '2025-11-21', '2025-10-21 15:18:22', '2026-01-21 15:18:57', 8, 8),
(256, 8, 8, '2025-09-26', 'Kang Sandi', NULL, 'Ciater, Subang', 1500, NULL, 'uploads/1764146830_PhotoGrid_Plus_1764146649122.jpg', 0, NULL, 'completed', '2025-11-26', '2025-10-21 15:48:06', '2026-01-21 15:15:29', 8, 8),
(257, 8, 7, '2025-10-12', 'Pak Kunyang', NULL, 'Bungursari, Purwakarta', 300, NULL, 'uploads/1762406031_PhotoGrid_Plus_1762405868180.jpg', 0, NULL, 'satisfactory', '2025-11-06', '2025-10-22 11:07:53', '2025-11-19 08:59:15', 8, 8),
(258, 8, 2, '2025-09-29', 'Pak Rasim', NULL, 'Bungursari, Purwakarta', 1000, NULL, 'uploads/1762405994_PhotoGrid_Plus_1762405834023.jpg', 0, NULL, 'completed', '2025-11-06', '2025-10-22 11:34:20', '2026-01-21 15:21:05', 8, 8),
(259, 8, 2, '2025-10-18', 'Pak Asnu', NULL, 'Bungursari, Purwakarta', 63000, NULL, 'uploads/1762415730_PhotoGrid_Plus_1762415639513.jpg', 0, NULL, 'completed', '2025-11-06', '2025-10-22 16:58:59', '2026-01-21 15:19:49', 8, 8),
(260, 8, 2, '2025-10-22', 'Pak Asnu', NULL, 'Bungursari, Purwakarta', 63000, NULL, 'uploads/1762415691_PhotoGrid_Plus_1762415605855.jpg', 0, NULL, 'completed', '2025-11-06', '2025-10-22 17:01:19', '2026-01-21 15:20:13', 8, 8),
(261, 15, 6, '2025-09-17', 'Bos Riyan', NULL, 'Pinggir sari , arjasari', 5000, NULL, 'uploads/1761133949_IMG-20251021-WA0029.jpeg', 1, 'Performa tanaman baik', 'not_yet_planted', NULL, '2025-10-22 18:52:30', '2025-10-22 18:53:10', 15, 15),
(262, 7, 2, '2025-10-11', 'Pak nur', NULL, 'Cibentar jatiwangi', 3, NULL, 'uploads/1761269638_1000588713.jpg', 1, NULL, 'not_yet_planted', NULL, '2025-10-24 08:33:58', NULL, 7, NULL),
(263, 5, 2, '2025-10-10', 'Mang likun', NULL, 'Weru lor', 15, NULL, 'uploads/1762966424_IMG20251110143153_01.jpg', 0, 'Penanaman jagung madu 15 pcs', 'satisfactory', '2025-12-03', '2025-10-24 09:02:40', '2026-01-12 16:01:26', 5, 5),
(264, 5, 2, '2025-10-18', 'Pamali', NULL, 'Sawah gede', 10, NULL, 'uploads/1762965988_IMG20251108134004.jpg', 0, NULL, 'satisfactory', '2025-11-28', '2025-10-24 13:39:30', '2026-01-12 16:04:30', 5, 5),
(265, 5, 2, '2025-10-21', 'Warma', NULL, 'Sawah gede', 10, NULL, 'uploads/1762965853_IMG20251108134120.jpg', 0, NULL, 'satisfactory', '2025-12-30', '2025-10-24 13:40:03', '2026-01-12 16:00:27', 5, 5),
(266, 5, 2, '2025-10-25', 'Rojai', NULL, 'Pamijahan plumbon', 10, NULL, 'uploads/1761869236_IMG20251014163058.jpg', 0, NULL, 'satisfactory', '2025-11-12', '2025-10-24 13:40:30', '2026-01-12 16:06:04', 5, 5),
(267, 5, 2, '2025-10-28', 'Ibu sarah', NULL, 'Sawah gede', 9, NULL, 'uploads/1762965176_IMG20251108134001.jpg', 0, NULL, 'satisfactory', '2025-12-30', '2025-10-24 13:40:57', '2026-01-12 16:00:13', 5, 5),
(268, 5, 1, '2025-10-18', 'Pamali', NULL, 'Sawah gede', 3, NULL, 'uploads/1762965744_IMG20251108134004_01.jpg', 0, NULL, 'satisfactory', '2025-11-12', '2025-10-24 13:41:16', '2026-01-12 16:05:32', 5, 5),
(269, 5, 1, '2025-10-28', 'Ibusarah', NULL, 'Sawah gede', 1, NULL, 'uploads/1762965059_IMG20251108133959_01.jpg', 0, NULL, 'satisfactory', '2025-11-12', '2025-10-24 13:42:03', '2026-01-12 16:05:51', 5, 5),
(270, 5, 2, '2025-10-17', 'Pak adi', NULL, 'Belakang baso mamah sarah', 10, NULL, 'uploads/1762965409_IMG20251108133104.jpg', 0, NULL, 'satisfactory', '2025-11-28', '2025-10-24 13:42:44', '2026-01-12 16:04:20', 5, 5),
(271, 7, 1, '2025-09-01', 'Pak ilal', NULL, 'Waringin', 3, NULL, 'uploads/1761622035_1000594008.jpg', 0, 'Petani binaan', 'satisfactory', '2025-10-28', '2025-10-28 10:27:15', '2026-01-15 20:01:05', 7, 7),
(272, 5, 2, '2025-10-04', 'Pak adi', NULL, 'Wanasaba belakang pohon nangka', 5, NULL, 'uploads/1761868962_IMG20251024124838.jpg', 0, NULL, 'satisfactory', '2025-11-12', '2025-10-31 07:02:42', '2026-01-12 16:05:42', 5, 5),
(273, 5, 2, '2025-10-15', 'Pak daryo', NULL, 'Talun', 4, NULL, 'uploads/1762964442_IMG20251108135221.jpg', 0, NULL, 'satisfactory', '2025-11-12', '2025-10-31 07:12:34', '2026-01-15 20:19:24', 5, 5),
(274, 8, 11, '2025-10-10', 'Pak Jeje', NULL, 'Ciater, Subang', 500, NULL, 'uploads/1764147000_PhotoGrid_Plus_1764146716662.jpg', 1, NULL, 'satisfactory', '2025-11-26', '2025-10-31 10:48:15', '2025-11-26 15:50:00', 8, 8),
(275, 5, 2, '2025-10-10', 'Erwan', NULL, 'Cikulak', 23, NULL, 'uploads/1761889406_IMG20251031111806.jpg', 0, 'Penanaman jagung madu 23 bungkus', 'satisfactory', '2025-12-15', '2025-10-31 12:43:26', '2026-01-12 15:59:15', 5, 5),
(276, 5, 4, '2025-10-21', 'Irman', NULL, 'Cikulak', 5, NULL, 'uploads/1761889650_IMG20251031112156.jpg', 0, NULL, 'satisfactory', '2025-12-29', '2025-10-31 12:47:30', '2026-01-12 15:59:39', 5, 5),
(277, 6, 6, '2025-10-10', 'Pak Saepudin', '+62 857-9521-0620', 'Ds. Kalapa Gunung Kec. Kramatmulya Kab. Kuningan', 800, NULL, 'uploads/1763464906_IMG_1359.jpeg', 0, NULL, 'completed', '2025-11-18', '2025-11-04 06:32:19', '2025-12-05 21:28:36', 6, 6),
(278, 6, 10, '2025-10-31', 'Pak Iwan', '+62 812-9598-1129', 'Ds. Gandasoli Kec. Kramatmulya Kab. Kuningan', 50, NULL, 'uploads/1762213109_aed329a7-e7e2-4237-b0e6-5674b70a5099.jpeg', 0, NULL, 'completed', '2025-11-03', '2025-11-04 06:38:29', '2026-01-13 18:09:53', 6, 6),
(279, 6, 2, '2025-10-15', 'Pak Jaja', '+62 853-1688-5409', 'Ds. Sidamulya Kec. Jalaksana Kab. Kuningan', 1500, NULL, 'uploads/1764142684_IMG_1645.jpeg', 0, NULL, 'completed', '2025-11-26', '2025-11-04 06:48:36', '2026-01-13 18:15:00', 6, 6),
(280, 6, 2, '2025-10-20', 'Pak Kusnadi', '+62 831-5322-2342', 'Ds. Pajambon Kec. Kramatmulya Kab. Kuningan', 3000, NULL, 'uploads/1767060161_IMG_2423.jpeg', 0, NULL, 'completed', '2025-12-30', '2025-11-04 07:01:54', '2026-02-24 14:57:11', 6, 6),
(281, 8, 2, '2025-10-23', 'Pak Ananto', NULL, 'Darangdan, Purwakarta', 42000, NULL, 'uploads/1762838100_PhotoGrid_Plus_1762837895246.jpg', 0, NULL, 'completed', '2025-11-11', '2025-11-11 12:15:00', '2026-01-21 15:19:22', 8, 8),
(282, 7, 2, '2025-09-22', 'Pak Nana', NULL, 'Pakubereum', 12, NULL, 'uploads/1762949156_1000615267.jpg', 0, NULL, 'completed', '2025-12-05', '2025-11-12 19:05:56', '2025-12-05 20:28:44', 7, 7),
(283, 5, 1, '2025-10-25', 'Rojai', NULL, 'Pamijahan', 4, NULL, 'uploads/1762964726_IMG20251110134152.jpg', 0, NULL, 'satisfactory', '2025-11-28', '2025-11-12 23:25:26', '2026-01-12 16:04:08', 5, 5),
(284, 5, 4, '2025-09-22', 'Pak Nana', NULL, 'Jatirenggang', 2, NULL, 'uploads/1762967487_IMG20251031135039.jpg', 0, NULL, 'satisfactory', '2025-12-02', '2025-11-13 00:11:27', '2026-01-12 16:03:42', 5, 5),
(285, 8, 6, '2025-10-30', 'Kang Aji', NULL, 'Ciater, Subang', 3000, NULL, 'uploads/1764135959_PhotoGrid_Plus_1764135040014.jpg', 0, NULL, 'completed', '2025-11-26', '2025-11-13 11:47:43', '2026-01-21 15:16:02', 8, 8),
(286, 8, 7, '2025-11-02', 'Pak Udin', NULL, 'Dawuan, Subang', 500, NULL, 'uploads/1763098370_PhotoGrid_Plus_1763098268330.jpg', 0, NULL, 'completed', '2025-11-21', '2025-11-13 14:42:01', '2026-01-21 15:17:32', 8, 8),
(287, 7, 7, '2025-10-26', 'H.sukardi (Amer)', NULL, 'SukagumiwangIndramayu', 500, NULL, 'uploads/1763083994_1000617263.jpg', 1, NULL, 'unsatisfactory', '2025-12-05', '2025-11-14 08:33:14', '2025-12-05 21:13:19', 7, 7),
(288, 7, 7, '2025-11-01', 'Donol', NULL, 'SukagumiwangIndramayu', 500, NULL, 'uploads/1763084055_1000617264.jpg', 1, NULL, 'unsatisfactory', '2025-12-05', '2025-11-14 08:34:16', '2025-12-05 21:13:51', 7, 7),
(289, 6, 2, '2025-10-05', 'Pak Hamdan', '+62 896-4899-9994', 'Ds. Cikaso Kec. Kramatmulya Kab. Kuningan', 1500, NULL, 'uploads/1763088310_IMG_1298.jpeg', 0, NULL, 'completed', '2025-11-14', '2025-11-14 09:45:10', '2026-01-13 18:12:37', 6, 6),
(290, 6, 8, '2025-09-01', 'Pak Obin', '+62 821-1929-9807', 'Ds. Cibulan Kec. Lemahsugih Kab. Majalengka', 2975, NULL, 'uploads/1763088545_IMG_1293.jpeg', 0, NULL, 'completed', '2025-11-13', '2025-11-14 09:49:06', '2025-12-05 21:02:48', 6, 6),
(291, 6, 8, '2025-10-06', 'Pak Marsa', '+62 852-6827-3734', 'Ds. Cipulus Kec. Cikijing Kab. Majalengka', 2000, NULL, 'uploads/1764943544_IMG_1769.jpeg', 0, NULL, 'completed', '2025-12-01', '2025-11-14 09:55:13', '2026-01-13 18:07:33', 6, 6),
(292, 7, 2, '2025-10-15', 'Pak nur', NULL, 'Cibentar', 3, NULL, 'uploads/1766669285_1000669849.jpg', 0, NULL, 'satisfactory', '2025-12-25', '2025-11-16 13:33:45', '2026-01-15 19:43:43', 7, 7),
(293, 7, 1, '2025-11-15', 'Pak ade', NULL, 'Ranji wetan', 2, NULL, 'uploads/1763274881_1000619831.jpg', 1, NULL, 'satisfactory', '2025-11-16', '2025-11-16 13:34:41', '2025-11-16 13:34:49', 7, 7),
(294, 7, 10, '2025-11-01', 'Pak yoyon', NULL, 'Ligung', 10, NULL, 'uploads/1763274958_1000620128.jpg', 1, NULL, 'satisfactory', '2025-11-16', '2025-11-16 13:35:58', '2025-11-16 13:36:07', 7, 7),
(295, 7, 7, '2025-11-01', 'H.abay', NULL, 'Majasuka', 1, NULL, 'uploads/1763275008_1000620126.jpg', 1, NULL, 'satisfactory', '2025-11-16', '2025-11-16 13:36:48', '2025-11-16 13:47:29', 7, 7),
(296, 7, 1, '2025-11-04', 'Ubay', NULL, 'Cijati', 3, NULL, 'uploads/1768481410_1000697278.jpg', 0, NULL, 'completed', '2026-01-15', '2025-11-16 13:43:05', '2026-01-15 19:52:17', 7, 7),
(297, 6, 8, '2025-10-13', 'Pak Riki', '+62 812-2458-9948', 'Ds. Sunia Kec. Banjaran Kab. Majalengka', 2000, NULL, 'uploads/1763464844_IMG_1350.jpeg', 0, NULL, 'completed', '2025-11-17', '2025-11-18 18:19:36', '2026-02-24 15:00:13', 6, 6),
(298, 6, 6, '2025-11-10', 'Pak Saepudin', '+62 857-9521-0620', 'Ds. Kalapagunung Kec. Kramatmulya Kab. Kuningan', 800, NULL, 'uploads/1763465063_IMG_1364.jpeg', 0, NULL, 'completed', '2025-11-18', '2025-11-18 18:24:23', '2026-02-24 14:59:24', 6, 6),
(299, 6, 6, '2025-10-18', 'Pak Unen', NULL, 'Ds. Kalapa Gunung Kec. Kramatmulya Kab. Kuningan', 2720, NULL, 'uploads/1763465224_IMG_1356.jpeg', 0, NULL, 'completed', '2025-11-18', '2025-11-18 18:27:05', '2025-12-25 20:08:11', 6, 6),
(300, 5, 2, '2025-10-11', 'Pak Armad binaan pak adi', NULL, 'Kubang', 7, NULL, 'uploads/1763521675_IMG20251114124116.jpg', 0, NULL, 'satisfactory', '2025-12-03', '2025-11-19 10:07:56', '2026-01-12 16:02:08', 5, 5),
(301, 5, 2, '2025-10-03', 'Mas Roni kubang', NULL, 'Kubang', 4, NULL, 'uploads/1763522039_IMG20251114124652.jpg', 0, NULL, 'satisfactory', '2025-12-03', '2025-11-19 10:13:59', '2026-01-12 16:02:35', 5, 5),
(302, 8, 2, '2025-11-03', 'Pak Carlan', NULL, 'Dawuan, Subang', 12000, NULL, 'uploads/1763708188_PhotoGrid_Plus_1763707853541.jpg', 0, NULL, 'completed', '2025-11-21', '2025-11-21 13:56:28', '2026-01-21 15:18:06', 8, 8),
(303, 15, 9, '2025-09-10', 'Abah ita', NULL, 'Pasir jambu ciwidey', 500, NULL, 'uploads/1763901158_IMG_20251123_193218.jpg', 1, 'Performa tanaman baik', 'not_yet_planted', NULL, '2025-11-23 19:32:39', NULL, 15, NULL),
(304, 6, 5, '2025-11-25', 'Pak Medi', NULL, 'Ds. Sidamulya Kec. Jalaksana Kab. Kuningan', 4760, NULL, 'uploads/1767789393_IMG_3092.jpeg', 0, NULL, 'completed', '2026-01-07', '2025-11-26 10:17:18', '2026-02-24 14:56:37', 6, 6),
(305, 6, 7, '2025-10-26', 'Pak Ryan', '+62 831-2094-4998', 'Ds. Jalaksana Kec. Jalaksana Kab. Kuningan', 2000, NULL, 'uploads/1765873706_IMG_2168.jpeg', 0, NULL, 'completed', '2025-12-15', '2025-11-26 10:19:34', '2026-01-13 18:04:42', 6, 6),
(306, 8, 6, '2025-10-20', 'Pak Eneb', NULL, 'Ciater, Subang', 3000, NULL, 'uploads/1764135762_PhotoGrid_Plus_1764134965075.jpg', 0, NULL, 'completed', '2025-11-26', '2025-11-26 12:42:42', '2026-01-21 15:16:33', 8, 8),
(307, 8, 8, '2025-11-30', 'Pak Maman', NULL, 'Ciater, Subang', 2000, NULL, 'uploads/1768982901_PhotoGrid_Plus_1768982835045.jpg', 1, 'DB 57%', 'satisfactory', '2026-01-21', '2025-11-26 15:52:12', '2026-01-21 15:08:40', 8, 8),
(308, 6, 2, '2025-11-18', 'Pak Samsudin', NULL, 'Ds. Karangsari Kec. Darma Kab. Kuningan', 4462, NULL, 'uploads/1764327881_IMG_1715.jpeg', 0, NULL, 'completed', '2025-11-28', '2025-11-28 18:04:42', '2026-02-24 14:58:44', 6, 6),
(309, 7, 7, '2025-11-04', 'Waddam', NULL, 'Ligung', 2600, NULL, 'uploads/1766669147_1000669848.jpg', 0, NULL, 'satisfactory', '2025-12-25', '2025-12-01 15:56:47', '2026-02-24 21:54:29', 7, 7),
(310, 7, 7, '2025-10-30', 'Pak daman', NULL, 'Girimukti', 2, NULL, 'uploads/1764581079_1000627171.jpg', 1, NULL, 'satisfactory', '2025-12-01', '2025-12-01 16:24:39', '2025-12-01 16:24:58', 7, 7),
(311, 6, 6, '2025-11-18', 'Pak Ihin', '0813-2375-6760', 'Ds. Sunia Kec. Banjaran Kab. Majalengka', 1500, NULL, 'uploads/1764631967_IMG-20251202-WA0000.jpg', 0, NULL, 'completed', '2025-12-02', '2025-12-02 06:32:47', '2026-02-24 14:58:06', 6, 6),
(312, 8, 8, '2025-10-15', 'Pak Maman', NULL, 'Ciater, Subang', 500, NULL, 'uploads/1764820971_PhotoGrid_Plus_1764820835786.jpg', 1, NULL, 'satisfactory', '2025-12-04', '2025-12-04 11:02:51', '2025-12-04 11:03:31', 8, 8),
(313, 5, 1, '2025-10-13', 'Hadi', NULL, 'Weru', 2, NULL, 'uploads/1764912642_IMG20251203111304.jpg', 0, NULL, 'satisfactory', '2025-12-03', '2025-12-05 12:30:42', '2026-01-12 16:03:10', 5, 5),
(314, 5, 2, '2025-10-18', 'Armad', NULL, 'Talun', 3, NULL, 'uploads/1764913090_IMG20251203111845.jpg', 0, NULL, 'satisfactory', '2025-12-03', '2025-12-05 12:38:10', '2026-01-12 16:01:48', 5, 5),
(315, 7, 2, '2025-10-07', 'Pak edi', NULL, 'Monjot kadipaten', 12, NULL, 'uploads/1764941419_1000645714.jpg', 0, NULL, 'satisfactory', '2025-12-05', '2025-12-05 20:30:19', '2026-01-15 19:43:23', 7, 7),
(316, 7, 10, '2025-12-09', 'Abah harun', NULL, 'Karyamukti', 12, NULL, 'uploads/1768481204_1000697276.jpg', 1, NULL, 'satisfactory', '2026-01-14', '2025-12-05 20:32:29', '2026-01-15 19:47:04', 7, 7),
(317, 7, 10, '2025-12-14', 'Pak darma', NULL, 'Banggala kertajati', 12, NULL, 'uploads/1768481277_1000697275.jpg', 1, NULL, 'satisfactory', '2026-01-15', '2025-12-05 20:33:25', '2026-01-15 19:48:08', 7, 7),
(318, 7, 2, '2025-12-05', 'Bos anton', NULL, 'Karyamukti', 7, NULL, 'uploads/1768481112_1000697277.jpg', 1, NULL, 'satisfactory', '2026-01-15', '2025-12-05 21:06:27', '2026-01-15 19:45:24', 7, 7),
(319, 6, 11, '2025-08-07', 'Pak Yuyu', NULL, 'Ds. Cipulus Kec. Cikijing Kab. Majalengka', 8000, NULL, 'uploads/1764943746_IMG_1911.jpeg', 0, NULL, 'completed', '2025-12-03', '2025-12-05 21:09:07', '2026-01-13 18:06:46', 6, 6),
(320, 6, 8, '2025-12-02', 'Pak Agung', NULL, 'Ds. Borogojol Kec. Lemahsugih Kab. Majalengka', 3300, NULL, 'uploads/1768194296_IMG_3206.jpeg', 1, NULL, 'satisfactory', '2026-01-12', '2025-12-05 21:11:36', '2026-01-12 12:04:57', 6, 6),
(321, 6, 11, '2025-08-07', 'Pak Wawan', NULL, 'Ds. Cipulus Kec. Cikijing Kab. Majalengka', 6000, NULL, 'uploads/1764944131_IMG_1793.jpeg', 0, NULL, 'completed', '2025-12-03', '2025-12-05 21:15:31', '2026-01-13 18:05:30', 6, 6),
(322, 7, 1, '2025-11-25', 'Dodo', NULL, 'Tarikolot palasah', 4, NULL, 'uploads/1768481564_1000697281.jpg', 1, NULL, 'satisfactory', '2026-01-15', '2025-12-05 21:20:13', '2026-01-15 19:52:54', 7, 7),
(323, 6, 9, '2025-11-08', 'Pak Dedi', NULL, 'Ds. Sukadana Kec. Argapura Kab. Majalengka', 1000, NULL, 'uploads/1766013595_IMG_2116.jpeg', 1, NULL, 'satisfactory', '2025-12-15', '2025-12-18 06:19:55', '2025-12-18 06:20:42', 6, 6),
(324, 6, 6, '2025-12-17', 'Pak Dadan', NULL, 'Ds. Cihaur Kec. Maja Kab. Majalengka', 1500, NULL, 'uploads/1766013771_0bbca3f7-db59-49cc-8c8d-8c42d6fb5609.jpeg', 1, NULL, 'satisfactory', '2025-12-17', '2025-12-18 06:22:51', '2025-12-18 06:23:17', 6, 6),
(325, 6, 8, '2025-12-02', 'Pak Nendi', NULL, 'Ds. Maja Kec. Maja Kab. Majalengka', 4000, NULL, 'uploads/1766013896_7a2c6fa5-dc43-4621-be92-2d404f265b80.jpeg', 1, NULL, 'satisfactory', '2025-12-16', '2025-12-18 06:24:56', '2025-12-18 06:25:16', 6, 6),
(326, 6, 8, '2025-12-25', 'Pak Anjar', NULL, 'Ds. Cisoka Kec. Cikijing Kab. Majalengka', 4500, NULL, 'uploads/1766668937_e6badcbd-9a46-40d5-826b-2b7c191fe1a1.jpeg', 1, NULL, 'satisfactory', '2025-12-25', '2025-12-18 06:30:08', '2025-12-25 20:23:38', 6, 6),
(327, 6, 7, '2025-12-23', 'Pak Gunawan', NULL, 'Ds. Kahiyangan Kec. Pancalang Kab. Kuningan', 2800, NULL, 'uploads/1767841847_IMG_3103.jpeg', 1, NULL, 'satisfactory', '2026-01-08', '2025-12-30 09:21:53', '2026-01-08 10:11:08', 6, 6),
(328, 6, 9, '2025-12-07', 'Pak Imam', NULL, 'Ds. Cisantana Kec. Cigugur Kab. Kuningan', 3500, NULL, 'uploads/1767789301_IMG_3077.jpeg', 1, NULL, 'satisfactory', '2026-01-07', '2026-01-07 19:35:02', '2026-01-07 19:35:28', 6, 6),
(329, 6, 8, '2025-10-29', 'Pak Emo', NULL, 'Ds. Borogojol Kec. Lemahsugih Kab. Majalengka', 3500, NULL, 'uploads/1768194138_IMG_3203.jpeg', 1, NULL, 'satisfactory', '2026-01-12', '2026-01-12 12:02:18', '2026-01-12 12:03:04', 6, 6),
(330, 6, 6, '2026-01-10', 'Pak Ahmad', NULL, 'Ds. Kalapa Gunung Kec. Kramatmulya Kab. Kuningan', 3500, NULL, 'uploads/1770606112_IMG_4234.jpeg', 1, NULL, 'satisfactory', '2026-02-09', '2026-01-13 18:03:03', '2026-02-09 10:01:52', 6, 6),
(331, 7, 7, '2026-01-01', 'Asep', NULL, 'Banggala', 2500, NULL, 'uploads/1771944912_1000743309.jpg', 1, NULL, 'satisfactory', '2026-02-24', '2026-01-15 19:49:19', '2026-02-24 21:55:32', 7, 7),
(332, 5, 18, '2026-01-06', 'Mas erwan', NULL, 'Cikulak', 9, '-6.8001549,108.6704377', 'uploads/1768481794_IMG20260112111823.jpg', 1, NULL, 'satisfactory', '2026-01-26', '2026-01-15 19:56:34', '2026-01-26 22:22:27', 5, 5),
(333, 5, 2, '2025-12-28', 'Erwan', NULL, 'Cikulak waled', 15, NULL, 'uploads/1768481965_IMG20260107131810.jpg', 1, 'Penanaman 25 namun DB hanya 65% sehingga disulam h72 sebanyak 9 bungkus', 'satisfactory', '2026-01-22', '2026-01-15 19:59:25', '2026-01-22 11:47:57', 5, 5),
(334, 7, 6, '2026-01-08', 'Pak sueb', NULL, 'Beber ligung', 2, NULL, 'uploads/1768481989_1000697286.jpg', 1, NULL, 'satisfactory', '2026-01-15', '2026-01-15 19:59:49', '2026-01-15 20:00:01', 7, 7),
(335, 5, 18, '2026-01-17', 'Pak haji Rohidi', NULL, 'Sumber Pabuaran', 5, NULL, 'uploads/1768482106_IMG20260114133741.jpg', 1, 'Penanaman dilaksanakan hariJumatatau sabtu', 'satisfactory', '2026-01-26', '2026-01-15 20:01:46', '2026-01-26 22:18:50', 5, 5),
(336, 5, 18, '2026-01-15', 'Mas toto', NULL, 'Pabuaran hulubanteng', 8, NULL, 'uploads/1769088631_IMG20260122120259.jpg', 1, NULL, 'satisfactory', '2026-01-26', '2026-01-15 20:04:51', '2026-01-26 22:15:29', 5, 5),
(337, 5, 12, '2026-01-20', 'Pak kadiro', NULL, 'Pabuaran', 8, NULL, 'uploads/1768482351_IMG20260114181502.jpg', 1, NULL, 'satisfactory', '2026-01-26', '2026-01-15 20:05:52', '2026-01-26 22:17:12', 5, 5),
(338, 5, 1, '2026-01-15', 'Pak haji Opik', NULL, 'Sumber', 4, NULL, 'uploads/1768482655_IMG20260107151009.jpg', 1, 'Benih disebar dipetani binannya', 'not_yet_planted', NULL, '2026-01-15 20:10:56', NULL, 5, NULL),
(339, 5, 18, '2026-01-15', 'Pak haji opik', NULL, 'Sumber', 4, NULL, 'uploads/1768482746_IMG20260107152223.jpg', 1, 'Benih disebar kepetani binannya', 'not_yet_planted', NULL, '2026-01-15 20:12:27', NULL, 5, NULL),
(340, 5, 1, '2026-01-21', 'Pa misba', NULL, 'Sumber Cirebon', 7, NULL, 'uploads/1771470523_IMG20260126105809.jpg', 1, NULL, 'satisfactory', '2026-01-24', '2026-01-15 20:14:14', '2026-02-19 10:08:44', 5, 5),
(341, 5, 18, '2026-01-15', 'Pak warma', NULL, 'Sumber cirebon', 2, NULL, 'uploads/1768482919_IMG20260104123341_01.jpg', 1, NULL, 'not_yet_planted', NULL, '2026-01-15 20:15:19', NULL, 5, NULL),
(342, 8, 2, '2025-12-29', 'Pak Jeje', NULL, 'Ciater, Subang', 6000, NULL, 'uploads/1772614348_PhotoGrid_Plus_1772614250220.jpg', 1, NULL, 'satisfactory', '2026-03-04', '2026-01-21 15:09:44', '2026-03-04 15:52:28', 8, 8),
(343, 7, 6, '2026-01-14', 'Pak dodo', NULL, 'CibuluhKertajati', 2, NULL, 'uploads/1771944813_1000742841.jpg', 1, NULL, 'satisfactory', '2026-02-24', '2026-01-21 18:53:43', '2026-02-24 21:53:58', 7, 7),
(344, 5, 18, '2026-01-24', 'Pak darma (h.darga)', NULL, 'Babakan (jalan kereta blegedog)', 14, '-6.6901653,108.4967865', 'uploads/1771469332_IMG-20260219-WA0039.jpg', 1, 'Lahan belum ditemukan masih mencari titik penanamannya', 'satisfactory', '2026-02-18', '2026-01-22 20:23:13', '2026-02-19 09:50:25', 5, 5),
(345, 5, 18, '2026-01-20', 'Pak idi (h.darga)', NULL, 'Tol pabuaran', 14, '-6.690151,108.4971574', 'uploads/1769088270_IMG20260122163123.jpg', 1, 'Lokasi masih dicari', 'not_yet_planted', NULL, '2026-01-22 20:24:30', NULL, 5, NULL),
(346, 5, 18, '2026-01-18', 'Pak sakir (h.darga)', NULL, 'Hulubanteng', 2, '-6.6901653,108.4967865', 'uploads/1771471198_IMG20260212105958.jpg', 1, 'Lahan masih dicari', 'satisfactory', '2026-03-02', '2026-01-22 20:26:30', '2026-03-02 12:40:12', 5, 5),
(347, 5, 18, '2026-01-22', 'Pak tarya (h.darga)', NULL, 'Tol pabuaran', 2, '-6.6908038,108.4967865', 'uploads/1769088448_IMG20260122163123.jpg', 1, NULL, 'not_yet_planted', NULL, '2026-01-22 20:27:29', NULL, 5, NULL),
(348, 5, 18, '2026-01-23', 'Arya dan ripai', NULL, 'Kalibangka, susukan, cikulak', 24, '-6.690151,108.4971574', 'uploads/1769088559_IMG20260122163124.jpg', 1, 'Penanaman hari jumat', 'not_yet_planted', NULL, '2026-01-22 20:29:19', NULL, 5, NULL),
(349, 5, 1, '2026-01-22', 'Pak adi', NULL, 'Talun', 9, NULL, 'uploads/1769440100_IMG20260124091449.jpg', 1, NULL, 'satisfactory', '2026-02-07', '2026-01-22 20:39:10', '2026-02-19 09:58:44', 5, 5),
(350, 5, 2, '2026-01-19', 'Pak adi', NULL, 'Kubang', 7, '-6.7734635,108.5068032', 'uploads/1770647758_IMG20260207144135.jpg', 1, NULL, 'satisfactory', '2026-02-07', '2026-01-22 20:39:50', '2026-02-19 09:55:19', 5, 5),
(351, 5, 12, '2026-01-17', 'Pak adi', NULL, 'Talun', 8, '-6.6928954,108.4976508', 'uploads/1769440314_IMG20260124091904.jpg', 1, 'L7 TD', 'satisfactory', '2026-02-19', '2026-01-22 20:40:25', '2026-02-19 09:56:35', 5, 5),
(352, 5, 1, '2025-12-05', 'Adi', NULL, 'Wanasaba talun', 9, NULL, 'uploads/1769438790_IMG20251219133014.jpg', 0, NULL, 'satisfactory', '2026-02-10', '2026-01-26 21:46:30', '2026-02-19 10:01:58', 5, 5),
(353, 5, 7, '2026-01-26', 'Roni (pak h.ali)', NULL, 'Kaligawe', 2, NULL, NULL, 1, NULL, 'not_yet_planted', NULL, '2026-01-26 22:27:59', NULL, 5, NULL),
(354, 5, 12, '2026-01-16', 'Pak mui', NULL, 'Pasaleman waled', 8, NULL, 'uploads/1769441475_IMG20260122132722.jpg', 1, NULL, 'satisfactory', '2026-01-22', '2026-01-26 22:31:15', '2026-01-26 22:33:10', 5, 5),
(355, 5, 18, '2026-01-16', 'Pak samiun (binaan pak mui)', NULL, 'Pasaleman waled', 2, NULL, 'uploads/1769441770_IMG20260122130722.jpg', 1, NULL, 'satisfactory', '2026-01-26', '2026-01-26 22:36:10', '2026-01-26 22:37:09', 5, 5),
(356, 5, 6, '2026-01-26', 'Pak subki', NULL, 'Pangenan', 4, NULL, 'uploads/1769442190_IMG20260115101452.jpg', 1, NULL, 'not_yet_planted', NULL, '2026-01-26 22:43:10', NULL, 5, NULL),
(357, 6, 6, '2026-01-16', 'Pak Ahmad', NULL, 'Ds. Kalapagunung Kec. Kramatmulya Kab. Kuningan', 3000, NULL, 'uploads/1770606201_IMG_4241.jpeg', 1, NULL, 'satisfactory', '2026-02-09', '2026-02-09 10:03:21', '2026-02-09 10:03:44', 6, 6),
(358, 6, 5, '2026-02-09', 'Pak Nurhaman', NULL, 'Ds. Salakadomas Kec. Mandirancan Kab. Kuningan', 600, NULL, 'uploads/1770900988_IMG_4255.jpeg', 1, NULL, 'satisfactory', '2026-02-10', '2026-02-12 19:56:28', '2026-02-12 19:56:50', 6, 6),
(359, 8, 9, '2025-12-04', 'Aji', NULL, 'Ciater, Subang', 1000, NULL, 'uploads/1771231548_PhotoGrid_Plus_1771227688329.jpg', 1, NULL, 'satisfactory', '2026-02-16', '2026-02-16 15:45:48', '2026-02-16 15:46:08', 8, 8),
(360, 5, 18, '2026-02-12', 'Mang kurman (pa darma)', NULL, 'Pabedilan', 15, NULL, 'uploads/1771469526_IMG20260218133138.jpg', 1, NULL, 'satisfactory', '2026-02-18', '2026-02-19 09:52:06', '2026-02-19 10:18:41', 5, 5),
(361, 5, 2, '2026-01-31', 'H.maman (binaan pa adi)', NULL, 'Talun', 8, NULL, 'uploads/1771470259_IMG20260207144024.jpg', 1, NULL, 'satisfactory', '2026-02-19', '2026-02-19 10:04:19', '2026-02-19 10:05:18', 5, 5),
(362, 5, 18, '2026-02-12', 'Karmadi (samping pa darma)', NULL, 'Pabedilan', 2, NULL, 'uploads/1771470981_IMG20260218133133.jpg', 1, NULL, 'satisfactory', '2026-02-18', '2026-02-19 10:16:21', '2026-02-19 10:17:31', 5, 5),
(363, 5, 18, '2026-02-19', 'Pa darma', NULL, 'Babakan pabuaran', 16, NULL, NULL, 1, NULL, 'not_yet_planted', NULL, '2026-02-19 10:18:09', NULL, 5, NULL),
(364, 5, 18, '2026-01-29', 'Pa jana sumber pabuaran', NULL, 'Pabuaran sumber', 15, NULL, 'uploads/1771471444_IMG20260218111359.jpg', 1, NULL, 'satisfactory', '2026-02-27', '2026-02-19 10:24:04', '2026-03-02 12:42:26', 5, 5),
(365, 6, 5, '2026-02-05', 'Pak Aman', NULL, 'Ds. Babakanmulya Kec. Jalaksana Kab. Majalengka', 6000, NULL, 'uploads/1771570829_IMG_4602.jpeg', 1, NULL, 'satisfactory', '2026-02-20', '2026-02-20 14:00:30', '2026-02-20 14:00:50', 6, 6),
(366, 5, 18, '2026-02-13', 'Kurman', NULL, 'Babakan', 15, NULL, 'uploads/1771599625_IMG20260220112314.jpg', 1, NULL, 'satisfactory', '2026-02-20', '2026-02-20 22:00:26', '2026-02-20 22:03:02', 5, 5),
(367, 5, 18, '2026-02-06', 'Pak irman', NULL, 'Susukan', 26, NULL, 'uploads/1771599892_IMG20260220140930.jpg', 1, NULL, 'satisfactory', '2026-02-20', '2026-02-20 22:04:53', '2026-02-20 22:08:48', 5, 5),
(368, 6, 8, '2026-02-17', 'Pak Diran', NULL, 'Ds. Sembawa Kec. Jalaksana Kab. Kuningan', 3500, NULL, 'uploads/1771821211_IMG_4634.jpeg', 1, NULL, 'satisfactory', '2026-02-23', '2026-02-23 11:33:31', '2026-02-23 11:34:05', 6, 6),
(369, 7, 7, '2026-01-06', 'Pak ujang', NULL, 'Kertajati', 1, NULL, 'uploads/1771945037_1000743308.jpg', 1, NULL, 'satisfactory', '2026-02-24', '2026-02-24 21:57:17', '2026-02-24 21:57:38', 7, 7),
(370, 7, 7, '2026-01-16', 'Abah otong', NULL, 'MaodinKertajati', 1, NULL, 'uploads/1771945114_1000743358.jpg', 1, NULL, 'satisfactory', '2026-02-24', '2026-02-24 21:58:35', '2026-02-24 21:58:50', 7, 7),
(371, 5, 18, '2026-02-13', 'Pa sidik', NULL, 'Hulubanteng', 10, NULL, 'uploads/1772429820_IMG20260302120253.jpg', 1, NULL, 'satisfactory', '2026-03-02', '2026-03-02 12:37:00', '2026-03-02 12:38:29', 5, 5),
(372, 5, 18, '2026-01-20', 'Pa budn', NULL, 'Pabedilan', 20, '-6.8860297,108.7227826', 'uploads/1772430245_IMG20260227113940.jpg', 1, NULL, 'satisfactory', '2026-02-27', '2026-03-02 12:44:06', '2026-03-02 12:45:56', 5, 5),
(373, 6, 11, '2026-01-30', 'Pak Iyad', NULL, 'Ds. Gunung manik kec. Talaga kab. Majalengka', 2000, NULL, 'uploads/1772492954_IMG_4797.jpeg', 1, NULL, 'satisfactory', '2026-03-02', '2026-03-03 06:09:14', '2026-03-03 06:09:48', 6, 6),
(374, 6, 8, '2026-02-10', 'Pak Iyad', NULL, 'Ds. Gunungmanik kec. Talaga kab. Majalengka', 3000, NULL, 'uploads/1772493167_IMG_4790.jpeg', 1, NULL, 'satisfactory', '2026-03-02', '2026-03-03 06:12:48', '2026-03-03 06:13:15', 6, 6),
(375, 6, 8, '2026-01-07', 'Pak Endang', NULL, 'Ds. Gunung manik kec. Talaga kab. Majalengka', 4500, NULL, 'uploads/1772592368_IMG_4773.jpeg', 1, NULL, 'satisfactory', '2026-03-02', '2026-03-04 09:46:08', '2026-03-04 09:47:09', 6, 6),
(376, 6, 8, '2026-01-21', 'Pak Iyan', NULL, 'Ds. Gunung manik kec. Talaga kab. Majalengka', 3000, NULL, 'uploads/1772592509_IMG_4765.jpeg', 1, NULL, 'satisfactory', '2026-03-02', '2026-03-04 09:48:29', '2026-03-04 09:49:26', 6, 6),
(377, 8, 8, '2026-02-12', 'Pak Jeje', NULL, 'Ciater, Subang', 1500, NULL, 'uploads/1772602994_PhotoGrid_Plus_1772602844914.jpg', 1, NULL, 'satisfactory', '2026-03-04', '2026-03-04 12:43:14', '2026-03-04 12:44:35', 8, 8),
(378, 8, 8, '2026-01-23', 'Pak Ojo', NULL, 'Ciater, Subang', 3000, NULL, 'uploads/1772614440_PhotoGrid_Plus_1772614291931.jpg', 1, NULL, 'satisfactory', '2026-03-04', '2026-03-04 15:54:00', '2026-03-04 15:54:42', 8, 8),
(379, 8, 18, '2026-02-02', 'Pak H Aa', NULL, 'Darangdan, Purwakarta', 216000, NULL, 'uploads/1772691289_PhotoGrid_Plus_1772691103081.jpg', 1, NULL, 'satisfactory', '2026-03-05', '2026-03-05 13:14:49', '2026-03-05 13:15:27', 8, 8),
(380, 8, 13, '2026-02-24', 'Pak Maman', NULL, 'Ciater, Subang', 1600, NULL, 'uploads/1773048913_PhotoGrid_Plus_1773048787855.jpg', 1, NULL, 'satisfactory', '2026-03-09', '2026-03-09 16:35:13', '2026-03-09 16:35:31', 8, 8);

-- --------------------------------------------------------

--
-- Table structure for table `demo_plot_visits`
--

CREATE TABLE `demo_plot_visits` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `demo_plot_id` bigint(20) UNSIGNED NOT NULL,
  `visit_date` date NOT NULL,
  `plant_status` enum('not_yet_planted','not_yet_evaluated','satisfactory','unsatisfactory','completed','failed') NOT NULL DEFAULT 'satisfactory',
  `latlong` varchar(100) DEFAULT NULL,
  `image_path` varchar(500) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_datetime` datetime DEFAULT NULL,
  `updated_datetime` datetime DEFAULT NULL,
  `created_by_uid` bigint(20) UNSIGNED DEFAULT NULL,
  `updated_by_uid` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `demo_plot_visits`
--

INSERT INTO `demo_plot_visits` (`id`, `user_id`, `demo_plot_id`, `visit_date`, `plant_status`, `latlong`, `image_path`, `notes`, `created_datetime`, `updated_datetime`, `created_by_uid`, `updated_by_uid`) VALUES
(1, 6, 18, '2025-07-14', 'satisfactory', NULL, 'uploads/1752472231_IMG_0669.jpeg', NULL, '2025-07-14 12:50:32', NULL, 6, NULL),
(2, 6, 19, '2025-07-14', 'satisfactory', NULL, 'uploads/1752479275_IMG_0685.jpeg', NULL, '2025-07-14 14:47:56', NULL, 6, NULL),
(3, 6, 20, '2025-07-14', 'completed', NULL, 'uploads/1752482524_IMG_0688.jpeg', NULL, '2025-07-14 15:42:05', '2025-08-01 11:40:56', 6, 6),
(4, 5, 30, '2025-07-15', 'satisfactory', NULL, 'uploads/1752568810_1752568778466750319645927772274.jpg', NULL, '2025-07-15 15:40:11', NULL, 5, NULL),
(5, 6, 41, '2025-07-16', 'satisfactory', NULL, 'uploads/1752648737_IMG_0731.jpeg', NULL, '2025-07-16 13:52:18', NULL, 6, NULL),
(6, 6, 42, '2025-07-16', 'satisfactory', NULL, 'uploads/1752651185_IMG_0742.jpeg', NULL, '2025-07-16 14:33:06', NULL, 6, NULL),
(7, 6, 43, '2025-07-16', 'satisfactory', NULL, 'uploads/1752651645_IMG_0753.jpeg', NULL, '2025-07-16 14:40:46', NULL, 6, NULL),
(8, 6, 45, '2025-07-16', 'satisfactory', NULL, 'uploads/1752662819_IMG_0770.jpeg', NULL, '2025-07-16 17:47:01', NULL, 6, NULL),
(9, 6, 46, '2025-07-16', 'satisfactory', NULL, 'uploads/1752663005_a0e71599-19c4-4f66-8e87-0cab2523779c.jpeg', NULL, '2025-07-16 17:50:05', NULL, 6, NULL),
(10, 5, 29, '2025-07-14', 'satisfactory', NULL, 'uploads/1752666585_IMG20250630110603.jpg', 'Kondisi terahir dipantauAlhamdulillahmasih aman terkendali', '2025-07-16 18:49:45', NULL, 5, NULL),
(11, 5, 28, '2025-07-14', 'satisfactory', NULL, 'uploads/1752666729_IMG20250630110612.jpg', 'Untuk terahir dipantau masih aman', '2025-07-16 18:52:09', '2025-07-16 18:52:20', 5, 5),
(12, 5, 40, '2025-07-16', 'satisfactory', NULL, 'uploads/1752667163_IMG20250509094207.jpg', 'Posisi tanaman belumterkontrol kembali', '2025-07-16 18:58:01', '2025-07-16 18:59:24', 5, 5),
(13, 5, 39, '2025-07-16', 'satisfactory', NULL, 'uploads/1753793072_IMG20250728153526.jpg', 'Pertumbuhan 90% karena waktu awal kerendam air', '2025-07-16 19:01:21', '2025-07-29 19:44:33', 5, 5),
(14, 5, 38, '2025-07-16', 'satisfactory', NULL, 'uploads/1752667427_IMG20250716101644.jpg', NULL, '2025-07-16 19:03:23', '2025-07-16 19:03:48', 5, 5),
(15, 5, 36, '2025-07-16', 'satisfactory', NULL, 'uploads/1752667478_IMG20250716094610.jpg', 'Sebagian sudah dipanenAlhamdulillahperforma maksimal dan memuaskan', '2025-07-16 19:04:39', NULL, 5, NULL),
(16, 5, 37, '2025-07-16', 'satisfactory', NULL, 'uploads/1752667537_IMG20250715094839.jpg', NULL, '2025-07-16 19:05:37', NULL, 5, NULL),
(17, 5, 35, '2025-07-11', 'satisfactory', NULL, 'uploads/1752667602_IMG-20250714-WA0069.jpg', 'Tanaman tidak seragam karena kerendam air hujan', '2025-07-16 19:06:42', NULL, 5, NULL),
(18, 5, 34, '2025-07-16', 'failed', NULL, 'uploads/1752667925_IMG20250616102549.jpg', 'Tanaman gagal karena pas awal kekeringan dan setelah masuk umur 30 kerendam air hujan', '2025-07-16 19:12:06', NULL, 5, NULL),
(19, 5, 33, '2025-07-16', 'satisfactory', NULL, 'uploads/1752668047_IMG20250618102241.jpg', '20% tanaman kebakar sehingga harus disulami. Ini foto terahir kontroldan selebihnyabelumterkontrol kembali', '2025-07-16 19:14:08', NULL, 5, NULL),
(20, 5, 32, '2025-07-16', 'completed', NULL, 'uploads/1752668094_IMG20250630112051.jpg', 'Tanaman terlewat karena banyak kegiatan sehingga panenan tidak terkawal.\r\nMengenai respon petani harga panenan selisih dan siwil selalu keluar', '2025-07-16 19:14:55', '2025-07-29 19:58:15', 5, 5),
(21, 5, 31, '2025-09-03', 'satisfactory', '-6.6913417,108.4993834', 'uploads/1756990730_IMG20250902153430.jpg', 'Baru sebar benih Lilac diseting per hari 5-10 bungkus ke petani binannya', '2025-07-16 19:16:23', '2025-09-26 06:58:00', 5, 5),
(22, 5, 27, '2025-07-14', 'unsatisfactory', NULL, 'uploads/1753794646_IMG20250723110601.jpg', 'Pertumbuhan Reva dimusim panas kurang cocok daya tumbuh kalah', '2025-07-16 19:19:05', '2025-09-04 19:43:42', 5, 5),
(23, 5, 48, '2025-07-16', 'satisfactory', NULL, 'uploads/1752678381_IMG20250716114138.jpg', 'Sebagian dititik penanaman lahan ini terendam banjir', '2025-07-16 22:06:21', NULL, 5, NULL),
(24, 5, 49, '2025-07-16', 'satisfactory', NULL, 'uploads/1752678532_IMG20250716114242.jpg', 'Penanaman 12 bungkus kekeringan 1 bungkus untuk tanaman jagung Lilac', '2025-07-16 22:08:52', NULL, 5, NULL),
(25, 5, 50, '2025-07-16', 'satisfactory', NULL, 'uploads/1752678674_IMG20250716114134.jpg', 'Pertumbuhan Alhamdulillah maksimal', '2025-07-16 22:11:15', NULL, 5, NULL),
(26, 5, 51, '2025-07-16', 'satisfactory', NULL, 'uploads/1752678775_IMG20250716113519.jpg', NULL, '2025-07-16 22:12:55', NULL, 5, NULL),
(27, 5, 52, '2025-07-16', 'unsatisfactory', NULL, 'uploads/1752679103_IMG20250616095342.jpg', 'Tanaman Kekeringan karenakurangair dankurang pupuk', '2025-07-16 22:18:23', NULL, 5, NULL),
(28, 6, 61, '2025-07-16', 'completed', NULL, 'uploads/1752710470_IMG_0775.jpeg', NULL, '2025-07-17 07:01:11', '2025-10-10 10:33:38', 6, 6),
(29, 6, 62, '2025-07-16', 'completed', NULL, 'uploads/1752710589_IMG_0776.jpeg', NULL, '2025-07-17 07:03:10', '2025-10-10 10:33:59', 6, 6),
(30, 7, 25, '2025-07-17', 'satisfactory', NULL, 'uploads/1752726573_1000456568.jpg', NULL, '2025-07-17 11:29:33', NULL, 7, NULL),
(31, 7, 24, '2025-07-17', 'satisfactory', NULL, NULL, NULL, '2025-07-17 11:35:13', NULL, 7, NULL),
(32, 7, 24, '2025-07-17', 'satisfactory', NULL, 'uploads/1752726923_1000456571.jpg', NULL, '2025-07-17 11:35:23', NULL, 7, NULL),
(33, 7, 23, '2025-07-17', 'satisfactory', NULL, 'uploads/1752728141_1000456630.jpg', NULL, '2025-07-17 11:55:41', NULL, 7, NULL),
(34, 5, 33, '2025-07-18', 'satisfactory', NULL, 'uploads/1752818165_Picsart_25-07-18_12-52-58-353.jpg', NULL, '2025-07-18 12:56:06', NULL, 5, NULL),
(35, 5, 63, '2025-07-18', 'satisfactory', NULL, 'uploads/1752821841_IMG20250718114639.jpg', NULL, '2025-07-18 13:57:22', NULL, 5, NULL),
(36, 7, 21, '2025-07-18', 'satisfactory', NULL, 'uploads/1752827069_1000458332.jpg', NULL, '2025-07-18 15:24:29', NULL, 7, NULL),
(37, 7, 47, '2025-07-19', 'not_yet_planted', NULL, 'uploads/1752889376_1000459264.jpg', NULL, '2025-07-19 08:42:56', '2025-07-19 08:43:19', 7, 7),
(38, 7, 26, '2025-07-19', 'satisfactory', NULL, 'uploads/1752889929_1000459266.jpg', NULL, '2025-07-19 08:52:09', NULL, 7, NULL),
(39, 7, 65, '2025-07-19', 'unsatisfactory', NULL, 'uploads/1752890105_1000459268.jpg', 'Kekeringan', '2025-07-19 08:55:05', NULL, 7, NULL),
(40, 7, 66, '2025-07-19', 'satisfactory', NULL, 'uploads/1752890440_1000459277.jpg', NULL, '2025-07-19 09:00:40', NULL, 7, NULL),
(41, 7, 69, '2025-07-21', 'satisfactory', NULL, 'uploads/1753105309_1000462558.jpg', NULL, '2025-07-21 20:41:49', NULL, 7, NULL),
(42, 6, 72, '2025-07-22', 'satisfactory', NULL, 'uploads/1753154611_IMG_1001.jpeg', NULL, '2025-07-22 10:23:31', NULL, 6, NULL),
(43, 8, 15, '2025-07-22', 'unsatisfactory', NULL, 'uploads/1753156587_20250722_104338.jpg', 'Terkena serangan ulat dan thrips dan banyak yg mati di awal penanaman', '2025-07-22 10:56:28', NULL, 8, NULL),
(44, 5, 63, '2025-07-21', 'satisfactory', NULL, 'uploads/1753185627_IMG20250718114741.jpg', 'Atur jadwal panenan rencana panen hari kamis', '2025-07-22 18:58:18', '2025-07-22 19:00:28', 5, 5),
(45, 5, 52, '2025-07-18', 'completed', NULL, 'uploads/1753185856_IMG20250718093950_01.jpg', 'Tanaman Kekeringan dan tidak dirawat sama petani', '2025-07-22 19:04:16', '2025-08-12 20:41:14', 5, 5),
(46, 5, 33, '2025-07-21', 'completed', NULL, 'uploads/1753185965_IMG-20250722-WA0045.jpg', 'studibanding dilahan pak wirto sekaligus melihat performa jagung manis madu bersama binaan bandar pak haji darga dan bandar pak carwan diwilayah hulubanteng sekaligus mencari spot lahan yang cocok untuk ditanam L7 dan persiapan tanam jagung madu kembali', '2025-07-22 19:06:06', '2025-07-29 19:56:52', 5, 5),
(47, 5, 51, '2025-07-22', 'satisfactory', NULL, 'uploads/1753186111_IMG20250722155335.jpg', 'Tanaman tumbuh optimal cuman 5% tertutup tanaman pisang sehingga ada yang pendek pertumbuhannya', '2025-07-22 19:08:32', NULL, 5, NULL),
(48, 5, 49, '2025-07-22', 'satisfactory', NULL, 'uploads/1753186189_Picsart_25-07-22_16-25-05-251.jpg', 'Sebagian tanaman Kekeringan dan terganggu pertumbuhannya respon petani dibandingkan dengan kompetitor tanaman Lilac masih kuat terhadap cuaca ekstream', '2025-07-22 19:09:49', '2025-07-29 19:36:19', 5, 5),
(49, 5, 48, '2025-07-22', 'satisfactory', NULL, 'uploads/1753186238_Picsart_25-07-22_16-25-05-251.jpg', NULL, '2025-07-22 19:10:38', NULL, 5, NULL),
(50, 5, 39, '2025-07-16', 'satisfactory', NULL, 'uploads/1753186412_IMG20250716101640.jpg', 'Untuk kontrolan terahirkondisi tanaman masih aman terkendali. Cuma yang paling ujung 2% rusak layu', '2025-07-22 19:13:33', NULL, 5, NULL),
(51, 5, 38, '2025-07-16', 'satisfactory', NULL, 'uploads/1753186495_IMG20250716100800.jpg', NULL, '2025-07-22 19:14:55', NULL, 5, NULL),
(52, 5, 64, '2025-07-21', 'satisfactory', NULL, 'uploads/1753186555_IMG20250721122356.jpg', 'Baru proses penanaman', '2025-07-22 19:15:56', NULL, 5, NULL),
(53, 5, 54, '2025-07-21', 'unsatisfactory', NULL, 'uploads/1753792157_IMG20250729111538.jpg', 'Terdapat serangan ulat dan tanaman Reva serta Anara ini diposisi panas kurang cocok karena rawan kresek daun', '2025-07-22 19:17:56', '2025-07-29 19:29:17', 5, 5),
(54, 5, 53, '2025-07-21', 'satisfactory', NULL, 'uploads/1753186788_IMG20250716113542.jpg', 'Terdapat serangan kresek daun uyukyanamanLilac. Untuk tanaman Reva terserang ulat', '2025-07-22 19:19:49', NULL, 5, NULL),
(55, 5, 35, '2025-07-22', 'satisfactory', NULL, 'uploads/1753793676_IMG-20250729-WA0057.jpg', 'Penanaman diwilayah palimanan masih aman namun ada beberapa tanaman yang pertumbuhannya tidak serempak karena mengalami musim kekeringan sehingga pertumbuhannya tidak seragam', '2025-07-22 19:23:24', '2025-07-29 19:55:31', 5, 5),
(56, 6, 74, '2025-07-22', 'satisfactory', NULL, 'uploads/1753189923_IMG_1003.jpeg', NULL, '2025-07-22 20:12:03', NULL, 6, NULL),
(57, 8, 12, '2025-07-23', 'satisfactory', NULL, 'uploads/1753234200_20250723_081959.jpg', 'Ketinggian +-900mdpl\r\nDaya tumbuh 85%\r\nTumbuh tidak merata, ada yg kerdil +-10%\r\nAda serangan ulat hanya sedikit\r\nDaun mulus belum ada serangan penyakit kresek daun dll.', '2025-07-23 08:30:01', NULL, 8, NULL),
(58, 5, 56, '2025-07-23', 'satisfactory', NULL, 'uploads/1753242289_IMG20250723104229_01.jpg', 'Tanaman masih aman namun terdapat serangan ulat respon petani mengenaidaya tumbuh sedikit lebih lambat dibanding kompetitor exotic dan tumbuhnya tidak merata. Untuk saat ini sedang diamati mengenai daya tahan terhadap cekaman lingkungan dan suhu', '2025-07-23 10:44:49', '2025-07-29 19:26:38', 5, 5),
(59, 8, 14, '2025-07-23', 'unsatisfactory', NULL, 'uploads/1753251419_PhotoGrid_Plus_1753251373154.jpg', 'Terkena serangan phytophtora', '2025-07-23 13:16:59', NULL, 8, NULL),
(60, 8, 13, '2025-07-24', 'completed', NULL, NULL, NULL, '2025-07-24 06:19:25', NULL, 8, NULL),
(61, 6, 19, '2025-07-24', 'satisfactory', NULL, 'uploads/1753321648_IMG_1047.jpeg', NULL, '2025-07-24 08:47:30', NULL, 6, NULL),
(62, 6, 18, '2025-07-24', 'satisfactory', NULL, 'uploads/1753329591_IMG_1057.jpeg', NULL, '2025-07-24 10:59:51', NULL, 6, NULL),
(63, 5, 63, '2025-07-24', 'completed', NULL, 'uploads/1753338465_Picsart_25-07-24_12-09-20-072.jpg', 'Penanaman 7 bungkus Alhamdulillah tonase masih keluar perkantong 4-5 kwintalan. Tonase eksotik lahan sebelah pe 19 bungkus keluar 8.4 ton, untuk lahan yang dioplos madu tembus 9.82 ton (madu 6 pcs) bisa memberi tambahan efek penambahan tonase', '2025-07-24 13:27:45', '2025-08-04 13:39:37', 5, 5),
(64, 7, 24, '2025-07-24', 'completed', NULL, NULL, NULL, '2025-07-24 13:38:39', NULL, 7, NULL),
(65, 7, 25, '2025-07-24', 'completed', NULL, NULL, NULL, '2025-07-24 13:39:53', NULL, 7, NULL),
(66, 5, 53, '2025-07-26', 'satisfactory', NULL, 'uploads/1753521032_IMG-20250726-WA0009.jpg', 'Persiapan panen dihari Rabu. Untuk serangan penyakit dipabedilan pada saat ini lumayan, ulat pada menetas', '2025-07-26 16:10:32', NULL, 5, NULL),
(67, 6, 77, '2025-07-28', 'completed', NULL, 'uploads/1753667871_IMG_1076.jpeg', NULL, '2025-07-28 08:57:53', '2025-12-05 21:21:16', 6, 6),
(68, 7, 78, '2025-07-28', 'satisfactory', NULL, 'uploads/1753668186_1000471152.jpg', NULL, '2025-07-28 09:03:06', NULL, 7, NULL),
(69, 7, 80, '2025-07-28', 'satisfactory', NULL, 'uploads/1753668433_1000471154.jpg', NULL, '2025-07-28 09:07:14', NULL, 7, NULL),
(70, 5, 51, '2025-07-28', 'completed', NULL, 'uploads/1753685361_IMG-20250728-WA0013.jpg', 'Fieldtrip panen jagung Lilac  Alhamdulillah respon petani bagus dan siap tanam kembali dan petani kunci ajak binaannya u tuk tanaman jagung Lilac dan madu. Sekaligus panen jagung madu untuk dan mengenalkan kepetani binaan bandar mas Sirod dan bandar smudi', '2025-07-28 13:49:22', NULL, 5, NULL),
(71, 5, 50, '2025-07-28', 'satisfactory', NULL, 'uploads/1753685479_IMG20250728103424.jpg', 'Persiapan hari Minggu panen', '2025-07-28 13:51:20', NULL, 5, NULL),
(72, 5, 40, '2025-07-26', 'completed', NULL, 'uploads/1753685610_Picsart_25-07-24_12-09-16-491.jpg', NULL, '2025-07-28 13:53:30', NULL, 5, NULL),
(73, 5, 38, '2025-07-28', 'satisfactory', NULL, 'uploads/1753685743_Picsart_25-07-28_13-46-24-439.jpg', 'Tanaman yang ini mengenai pengairan terganggu namun respon petani dibeberapa titik jagung madu masih kuatwalaupunkekurangan air namun siwil untuk saat ini masih menjadi hambatan petani', '2025-07-28 13:55:43', '2025-07-29 19:47:40', 5, 5),
(74, 5, 36, '2025-07-28', 'completed', NULL, 'uploads/1753685894_IMG20250728135749.jpg', 'Proses pasca panen dan persiapan tanam reva1 dus. Petani masih penasaran terhadap perkembangan jagung Reva', '2025-07-28 13:58:14', '2025-07-29 19:50:34', 5, 5),
(75, 5, 37, '2025-07-28', 'satisfactory', NULL, 'uploads/1753793384_IMG20250725134136.jpg', 'Pertumbuhan Lilac hampir 99% bagus respon petanimengenai ketertarikan tanam Alhamdulillah bagus dan rencana akan difokuskan khusus untuk penanaman panen tahun baru', '2025-07-28 14:00:49', '2025-07-29 19:49:44', 5, 5),
(76, 7, 47, '2025-07-28', 'satisfactory', '-6.8025316,108.1756158', 'uploads/1753691866_1000471749.jpg', NULL, '2025-07-28 15:37:47', NULL, 7, NULL),
(77, 5, 82, '2025-07-28', 'satisfactory', NULL, 'uploads/1753693807_IMG20250728152240_01.jpg', 'Pertumbuhan jagung madu 90% karena waktu treethment benih dikasih air sehinggabeberapa benih yang ditanam busuk dan tidak tumbuh', '2025-07-28 16:07:01', '2025-07-29 19:20:40', 5, 5),
(78, 5, 39, '2025-07-28', 'satisfactory', NULL, 'uploads/1753693850_IMG20250728153536.jpg', 'Pertumbuhan untuk saat terahir kali masih aman petani menyeting panenan diumur 74 supaya jagung tidak kegedean dan cepat habis untuk pengecer rebusan. Mengenai respon pembeli jagung madu banyak diminati karena rasa manis dan ukurannyayang super', '2025-07-28 16:10:51', '2025-07-29 19:46:14', 5, 5),
(79, 7, 84, '2025-07-28', 'satisfactory', NULL, 'uploads/1753696015_PSX_20250728_155355.jpg', NULL, '2025-07-28 16:46:56', NULL, 9, NULL),
(80, 7, 86, '2025-07-09', 'completed', NULL, 'uploads/1753747252_IMG-20240926-WA0019.jpg', NULL, '2025-07-29 07:00:52', NULL, 7, NULL),
(81, 8, 12, '2025-07-29', 'satisfactory', NULL, 'uploads/1753760652_20250729_103845.jpg', '- Kondisi tanaman mulai terkena serangan hama ulat\r\n- Baru muncul bakal buah', '2025-07-29 10:44:12', NULL, 8, NULL),
(82, 7, 87, '2025-04-08', 'completed', NULL, 'uploads/1753765948_IMG-20250204-WA0072.jpg', NULL, '2025-07-29 12:12:28', NULL, 7, NULL),
(83, 6, 88, '2025-07-29', 'completed', NULL, NULL, NULL, '2025-07-29 12:14:06', NULL, 6, NULL),
(84, 7, 89, '2025-05-05', 'completed', NULL, 'uploads/1753766427_IMG-20250428-WA0026.jpg', NULL, '2025-07-29 12:20:27', '2025-07-29 12:22:26', 7, 7),
(85, 6, 90, '2025-04-30', 'satisfactory', NULL, 'uploads/1753767093_b6de88b5-40da-4db9-8c98-5ed7508ea8d5.jpeg', NULL, '2025-07-29 12:31:34', NULL, 6, NULL),
(86, 6, 42, '2025-05-26', 'satisfactory', NULL, 'uploads/1753767329_6bc82f35-477f-4334-a892-e731399e3c3f.jpeg', NULL, '2025-07-29 12:35:29', NULL, 6, NULL),
(87, 6, 90, '2025-05-28', 'satisfactory', NULL, 'uploads/1753767433_05a3d94c-9b21-470e-a354-e81e7baa7e61.jpeg', NULL, '2025-07-29 12:37:13', NULL, 6, NULL),
(88, 7, 91, '2025-06-23', 'satisfactory', NULL, 'uploads/1753767566_IMG-20250609-WA0025.jpg', NULL, '2025-07-29 12:39:26', '2025-07-29 13:47:53', 7, 7),
(89, 7, 91, '2025-07-18', 'completed', NULL, NULL, NULL, '2025-07-29 12:39:44', NULL, 7, NULL),
(90, 6, 92, '2025-05-30', 'satisfactory', NULL, 'uploads/1753767780_e923fbad-9c81-4a4f-814b-c8f6cf0597cc.jpeg', NULL, '2025-07-29 12:43:00', NULL, 6, NULL),
(91, 6, 90, '2025-06-03', 'completed', NULL, 'uploads/1753769369_6c189586-91d1-416a-8e6a-55030b05b1da.jpeg', NULL, '2025-07-29 13:09:29', '2025-07-29 14:01:41', 6, 6),
(92, 6, 18, '2025-06-11', 'satisfactory', NULL, 'uploads/1753769578_ca159df6-f04c-4057-b4fe-c7cb8f861226.jpeg', NULL, '2025-07-29 13:12:58', NULL, 6, NULL),
(93, 6, 19, '2025-06-12', 'satisfactory', NULL, 'uploads/1753769910_7d7ddf23-88c6-4d71-9bea-d2befcf2b76a.jpeg', NULL, '2025-07-29 13:18:30', NULL, 6, NULL),
(94, 6, 94, '2025-06-13', 'satisfactory', NULL, 'uploads/1753770133_0116c44e-bf2d-4610-a381-ab89dd13070d.jpeg', NULL, '2025-07-29 13:22:13', NULL, 6, NULL),
(95, 6, 92, '2025-06-17', 'completed', NULL, 'uploads/1753770279_24c5847b-6bad-46fa-b496-f7db323f1dad.jpeg', NULL, '2025-07-29 13:24:39', NULL, 6, NULL),
(96, 7, 70, '2025-07-29', 'satisfactory', NULL, 'uploads/1753770387_IMG-20250725-WA0016.jpg', NULL, '2025-07-29 13:26:27', NULL, 7, NULL),
(97, 6, 95, '2025-06-18', 'satisfactory', NULL, 'uploads/1753770551_689e4444-9d29-413e-9096-2859f70a3e61.jpeg', NULL, '2025-07-29 13:29:11', NULL, 6, NULL),
(98, 6, 18, '2025-06-20', 'satisfactory', NULL, 'uploads/1753770696_8e81b50d-b659-4406-8735-2a9378c88c9a.jpeg', NULL, '2025-07-29 13:31:36', NULL, 6, NULL),
(99, 6, 96, '2025-06-20', 'completed', NULL, 'uploads/1753770985_c49cc1c5-e292-4941-960f-9099d1cefd3e.jpeg', NULL, '2025-07-29 13:36:25', '2025-07-29 13:55:40', 6, 6),
(100, 6, 94, '2025-06-21', 'completed', NULL, 'uploads/1753771117_07e768a0-895d-443e-b537-425fe033c719.jpeg', 'Dijadikan Field Trip', '2025-07-29 13:38:38', '2025-07-29 13:57:27', 6, 6),
(101, 6, 98, '2025-06-21', 'completed', NULL, 'uploads/1753771384_1341faf1-cc99-4e86-ae06-437493b73378.jpeg', NULL, '2025-07-29 13:43:05', '2025-07-29 13:55:04', 6, 6),
(102, 6, 95, '2025-06-30', 'satisfactory', NULL, 'uploads/1753771520_f4dbd838-4e81-456d-bfeb-728aa48c621e.jpeg', NULL, '2025-07-29 13:45:20', NULL, 6, NULL),
(103, 6, 95, '2025-07-04', 'completed', NULL, 'uploads/1753771674_a94cb9e3-1b51-4f13-9a9a-1c763c4278a1.jpeg', NULL, '2025-07-29 13:47:54', '2025-07-29 13:56:14', 6, 6),
(104, 6, 93, '2025-07-29', 'completed', NULL, 'uploads/1753772309_4de66a8d-0570-4e2c-92c4-3443f33f3255.jpeg', NULL, '2025-07-29 13:58:29', NULL, 6, NULL),
(105, 6, 76, '2025-07-29', 'failed', NULL, 'uploads/1753772646_5fc8ae55-a3cc-4cb3-a162-86f141eced59.jpeg', NULL, '2025-07-29 14:04:06', NULL, 6, NULL),
(106, 6, 75, '2025-07-25', 'unsatisfactory', NULL, 'uploads/1753772894_IMG_1097.jpeg', NULL, '2025-07-29 14:08:15', NULL, 6, NULL),
(107, 6, 75, '2025-07-29', 'completed', NULL, 'uploads/1753772953_8cfe23a8-7762-42fb-9aec-e56698ded545.jpeg', NULL, '2025-07-29 14:09:13', '2025-09-30 16:17:17', 6, 6),
(108, 6, 71, '2025-07-25', 'satisfactory', NULL, NULL, NULL, '2025-07-29 14:12:08', NULL, 6, NULL),
(109, 6, 44, '2025-07-29', 'satisfactory', NULL, NULL, NULL, '2025-07-29 14:17:04', NULL, 6, NULL),
(110, 5, 54, '2025-07-29', 'unsatisfactory', NULL, 'uploads/1753792251_IMG20250729111523.jpg', 'Tanaman Reva dan Anara untuk musim sekarang terkhusus dimusimkemaridaya tahannya kurang optimal', '2025-07-29 19:16:15', '2025-07-29 19:30:51', 5, 5),
(111, 5, 83, '2025-07-25', 'satisfactory', NULL, 'uploads/1753791586_IMG20250725133329.jpg', 'Performa Alhamdulillah maksimal daya tumbuh 95% , .mengenai hama dan penyakit diwilayah barat masih aman, namun pengairan sedikit terganggu', '2025-07-29 19:19:47', NULL, 5, NULL),
(112, 5, 81, '2025-07-28', 'satisfactory', NULL, 'uploads/1753791745_IMG20250728153536.jpg', 'Pertumbuhan Alhamdulillah masih aman. Namun hama ulat dilahan inibanyak sehingga pemberian insektisida dilakukan secara intensif', '2025-07-29 19:22:26', NULL, 5, NULL),
(113, 5, 64, '2025-07-23', 'satisfactory', NULL, 'uploads/1753791880_IMG20250724082750_01.jpg', 'Benih baru pada tumbuh yang terlihat baru 50%', '2025-07-29 19:24:40', NULL, 5, NULL),
(114, 5, 53, '2025-08-01', 'completed', NULL, 'uploads/1753792329_IMG-20250729-WA0038.jpg', 'Tanaman ini digunakan untuk Farmer meteeng bersama binaan mas Basyar mengenalkan jagung Reva sekaligus panen jagung Lilac Alhamdulillah respon petani diwilayah sini tertarik tanam jagung Lilac', '2025-07-29 19:32:09', '2025-08-04 13:58:02', 5, 5),
(115, 5, 50, '2025-07-29', 'satisfactory', NULL, 'uploads/1753792486_IMG20250728103435.jpg', 'Respon petani mengenai jagung madu dari segi ukuran cocok dan gede super. Namun mengenai siwil itu dari petani menjadi faktor hambatan karena harus tenaga 2x', '2025-07-29 19:34:46', NULL, 5, NULL),
(116, 5, 48, '2025-07-29', 'satisfactory', NULL, 'uploads/1754288732_IMG20250804121140.jpg', 'Fu jagung madu dan melihat lilac. Respon petani mengenai jagung Lilac bagus, disampingharga bagus daya tumbuh juga optimal. Untuk respon jagung madu sendiri pertumbuhan bagus namun siwil terlalu banyak', '2025-07-29 19:39:44', '2025-08-04 13:25:32', 5, 5),
(117, 8, 99, '2025-04-30', 'completed', NULL, 'uploads/1753793724_20250430_111107.jpg', 'Plan Kegiatan FT bulan Mei', '2025-07-29 19:55:25', '2025-07-29 20:01:33', 8, 8),
(118, 8, 100, '2025-05-14', 'completed', NULL, 'uploads/1753794044_20250514_111300.jpg', 'Plan Kegiatan FT bulan Juni', '2025-07-29 20:00:46', NULL, 8, NULL),
(119, 5, 30, '2025-07-17', 'completed', NULL, 'uploads/1753794108_IMG-20250714-WA0104(1).jpg', 'Studi banding bersama petani kunci pak Arifin dan binannya diwilayah Dukuhwidara menuju kalimukti sekaligus melihat performa jagung madu dilahan pak Arifin. Alhamdulillah persiapan tanam 5 bungkus jagung madu dan Lilac 5 bungkus dipabedilan, Cirebon', '2025-07-29 20:01:48', '2025-07-29 20:01:56', 5, 5),
(120, 5, 29, '2025-07-29', 'satisfactory', NULL, 'uploads/1753794298_IMG20250723105953_01.jpg', 'Pertumbuha masih aman hama da npenyakit juga masih aman. Respon petani setelah panen ke 4 ini, minat petani masih suka kelilac dibandingkan dengan yg ungu lainnya. Karena besar dan pulen rasanya', '2025-07-29 20:04:59', NULL, 5, NULL),
(121, 8, 101, '2025-05-30', 'completed', NULL, 'uploads/1753794362_20250530_110050.jpg', 'Plan Kegiatan FT bulan Juni', '2025-07-29 20:06:03', NULL, 8, NULL),
(122, 5, 28, '2025-07-29', 'satisfactory', NULL, 'uploads/1753794545_IMG20250723110010_01.jpg', 'Tanaman dilahn ini untuk pertumbuhan LilacAlhamdulillahoptimal namun hama ulat sedang menyerang diwilayah tersebut', '2025-07-29 20:09:05', NULL, 5, NULL),
(123, 8, 102, '2025-07-04', 'completed', NULL, 'uploads/1753795015_20250704_103250.jpg', 'Plan Kegiatan FT Bulan Juli', '2025-07-29 20:16:56', '2025-07-29 20:17:05', 8, 8),
(124, 8, 103, '2025-07-02', 'completed', NULL, 'uploads/1753795489_20250630_092847.jpg', 'Plan kegiatan FT bulan Juli', '2025-07-29 20:24:50', NULL, 8, NULL),
(125, 8, 104, '2025-07-04', 'completed', NULL, 'uploads/1753795698_20250704_115422.jpg', 'Tidak dijadikan kegiatan FT karena pertumbuhan kurang maksimal', '2025-07-29 20:28:19', NULL, 8, NULL),
(126, 7, 105, '2025-04-27', 'completed', NULL, 'uploads/1753795706_IMG-20250729-WA0035.jpg', NULL, '2025-07-29 20:28:26', NULL, 7, NULL),
(128, 7, 109, '2025-05-13', 'completed', NULL, 'uploads/1754064109_1000477838.jpg', NULL, '2025-07-29 20:49:57', '2025-08-01 23:01:49', 7, 7),
(129, 6, 111, '2025-07-30', 'satisfactory', NULL, 'uploads/1753851914_IMG_1210.jpeg', NULL, '2025-07-30 12:05:14', NULL, 6, NULL),
(130, 8, 112, '2025-07-30', 'unsatisfactory', NULL, 'uploads/1753856737_20250730_125948.jpg', 'Pertumbuhan agak terlambat karena sempat tertutup sama penanaman tumpangsari nya (timun)', '2025-07-30 13:25:38', NULL, 8, NULL),
(131, 5, 64, '2025-07-30', 'satisfactory', '-6.9029273,108.7090526', 'uploads/1753860219_IMG-20250730-WA0025.jpg', 'AlhamdulillahpertumbuhanRevadanAnaratumbuh dengan optimal namun settingan tanam 2:1 karena antisipasi gagal tumbuh', '2025-07-30 14:23:40', NULL, 5, NULL),
(132, 8, 114, '2025-07-31', 'satisfactory', NULL, 'uploads/1753937983_20250731_115513.jpg', 'Rencana kegiatan FFD agustus', '2025-07-31 11:59:44', NULL, 8, NULL),
(134, 6, 19, '2025-08-01', 'satisfactory', NULL, 'uploads/1754023127_IMG_1305.jpeg', NULL, '2025-08-01 11:38:48', NULL, 6, NULL),
(135, 6, 116, '2025-08-01', 'satisfactory', NULL, 'uploads/1754030315_IMG_1297.jpeg', NULL, '2025-08-01 13:38:36', NULL, 6, NULL),
(136, 8, 108, '2025-08-01', 'satisfactory', NULL, 'uploads/1754032806_20250801_141505.jpg', 'Pertumbuhan baik, ada terkena serangan thrips dan tungau', '2025-08-01 14:20:08', NULL, 8, NULL),
(137, 7, 117, '2025-06-14', 'completed', NULL, 'uploads/1754063695_1000477836.jpg', NULL, '2025-08-01 22:54:55', NULL, 7, NULL),
(138, 7, 65, '2025-06-20', 'completed', NULL, NULL, NULL, '2025-08-01 23:04:05', NULL, 7, NULL),
(139, 7, 22, '2025-08-01', 'satisfactory', NULL, NULL, 'Tidak pakai lanjaran', '2025-08-01 23:07:40', NULL, 7, NULL),
(140, 6, 18, '2025-08-01', 'satisfactory', NULL, 'uploads/1754105341_IMG_1313.jpeg', NULL, '2025-08-02 10:29:01', NULL, 6, NULL),
(141, 7, 69, '2025-08-03', 'satisfactory', NULL, 'uploads/1754215453_1000480019.jpg', NULL, '2025-08-03 17:04:14', NULL, 7, NULL),
(142, 7, 84, '2025-08-01', 'satisfactory', NULL, 'uploads/1754223358_1000480202.jpg', NULL, '2025-08-03 19:15:58', NULL, 7, NULL),
(144, 5, 119, '2025-08-02', 'satisfactory', NULL, 'uploads/1754268959_Picsart_25-08-02_12-19-18-007.jpg', 'Penanaman jagung Reva diwilayah wanasaba kidul', '2025-08-04 07:55:59', NULL, 5, NULL),
(145, 5, 55, '2025-07-30', 'satisfactory', NULL, 'uploads/1754269122_Picsart_25-07-30_17-41-36-488.jpg', 'Pertumbuhan tanaman reva ditempat yang airnya optimal tumbuh dengan seragam dan optimal', '2025-08-04 07:58:43', NULL, 5, NULL),
(146, 5, 50, '2025-07-30', 'completed', NULL, 'uploads/1754269458_IMG20250728101553.jpg', 'Panen jagung madu dilahan mang likun. Untuk tonasepanentanam 4bungkusmendapatkan 1.89 kwintal, dari segi tonase petani senang namun dari segi perawatan terbilang cukup melelahkan karena harus rutin membuang siwil yang ada ditanaman madu tersebut', '2025-08-04 08:04:19', NULL, 5, NULL),
(147, 5, 49, '2025-08-02', 'satisfactory', NULL, 'uploads/1754269570_IMG20250802150029.jpg', 'Atur jadwal hari minggudilakukanproses pemanenan', '2025-08-04 08:06:11', NULL, 5, NULL),
(148, 5, 49, '2025-08-03', 'completed', NULL, 'uploads/1754269715_IMG20250803085846.jpg', 'Tanaman jagung Lilac dipanen 3 tahap karena penanaman dilakukan 3x jeda 1 hari respon petani untukLilac dimusim ini terkendala air jadi pertumbuhannya tidak serempak 98% seperti biasanya tapi respon lainnya petani akan tanam lagi karena sudah tau karakter', '2025-08-04 08:08:36', NULL, 5, NULL),
(149, 6, 120, '2025-08-01', 'satisfactory', NULL, 'uploads/1754275313_IMG_1311.jpeg', NULL, '2025-08-04 09:41:54', NULL, 6, NULL),
(150, 6, 71, '2025-08-04', 'satisfactory', NULL, 'uploads/1754279895_7a5adb13-9d7f-4ccc-951b-f20ab632cc32.jpeg', NULL, '2025-08-04 10:58:16', NULL, 6, NULL),
(151, 5, 113, '2025-08-01', 'satisfactory', NULL, 'uploads/1754288002_IMG20250801125006.jpg', 'DB jagung madu dilahan L7 hanya 67%', '2025-08-04 13:13:22', NULL, 5, NULL),
(152, 5, 64, '2025-08-01', 'satisfactory', NULL, 'uploads/1754288403_IMG20250730133306_01.jpg', 'Performa pertumbuhan alhamdulilah seragam ditanam disamping lahan l7', '2025-08-04 13:20:04', NULL, 5, NULL),
(153, 5, 48, '2025-08-04', 'satisfactory', NULL, 'uploads/1754288807_IMG20250802150024.jpg', 'Atur jadwal 2 hari kembali persiapan jagung madu ada yang dipeting', '2025-08-04 13:26:47', NULL, 5, NULL),
(154, 5, 81, '2025-08-02', 'satisfactory', NULL, 'uploads/1754289049_Picsart_25-08-02_11-32-50-460.jpg', 'Pertumbuhan jagung madu optimal kelemahan Masih disiwil mengenai umur diwilayah ini tidak menjadi masalah', '2025-08-04 13:30:49', NULL, 5, NULL),
(155, 8, 12, '2025-08-05', 'satisfactory', NULL, 'uploads/1754363329_20250805_100527.jpg', 'Waktu nya panen semi / putren\r\nKondisi tanaman masih aman dari serangan hama ulat dan penyakit hawar daun.', '2025-08-05 10:08:50', NULL, 8, NULL),
(156, 7, 26, '2025-08-05', 'satisfactory', NULL, 'uploads/1754372808_1000482427.jpg', NULL, '2025-08-05 12:46:49', NULL, 7, NULL),
(158, 7, 69, '2025-08-05', 'completed', NULL, NULL, NULL, '2025-08-05 20:34:49', NULL, 7, NULL),
(159, 6, 127, '2025-08-06', 'satisfactory', NULL, 'uploads/1754446306_IMG_1383.jpeg', NULL, '2025-08-06 09:11:47', NULL, 6, NULL),
(160, 5, 126, '2025-08-04', 'satisfactory', '-6.7276041,108.4294861', 'uploads/1754446389_IMG20250804120735_01.jpg', 'Pertumbuhan jagung Lilac dilahan pak haji bun', '2025-08-06 09:13:09', NULL, 5, NULL),
(161, 5, 128, '2025-08-04', 'satisfactory', '-6.7275998,108.4294865', 'uploads/1754446538_IMG20250804120740_01.jpg', 'Monitoring lahan penanaman jagung Lilac milik pak likun diweru', '2025-08-06 09:15:38', NULL, 5, NULL),
(162, 6, 132, '2025-08-07', 'satisfactory', NULL, 'uploads/1754530961_IMG_1420.jpeg', NULL, '2025-08-07 08:42:41', NULL, 6, NULL),
(163, 7, 67, '2025-08-07', 'satisfactory', NULL, 'uploads/1754540204_1000484823.jpg', NULL, '2025-08-07 11:16:44', NULL, 7, NULL),
(164, 6, 133, '2025-08-07', 'satisfactory', NULL, 'uploads/1754540281_55b0376f-8bf6-4f1c-8476-307a163bc130.jpeg', NULL, '2025-08-07 11:18:01', NULL, 6, NULL),
(165, 6, 134, '2025-08-07', 'satisfactory', NULL, 'uploads/1754540439_IMG_1434.jpeg', NULL, '2025-08-07 11:20:40', NULL, 6, NULL),
(166, 6, 72, '2025-08-06', 'satisfactory', NULL, 'uploads/1754552617_IMG_1399.jpeg', NULL, '2025-08-07 14:43:38', NULL, 6, NULL),
(167, 8, 110, '2025-08-07', 'unsatisfactory', NULL, 'uploads/1754563931_PhotoGrid_Plus_1754563908235.jpg', 'Pertumbuhan terlambat karna tertutup tanaman tomat sebelumnya.\r\nKondisi ham & penyakit tidak terkena virus gemini hanya ada serangan ulat dan thrips', '2025-08-07 17:52:12', NULL, 8, NULL),
(168, 8, 135, '2025-08-08', 'satisfactory', NULL, 'uploads/1754624199_20250808_102655.jpg', 'Kondisi tanaman ada gejala terkena serangan hawar daun', '2025-08-08 10:36:40', NULL, 8, NULL),
(169, 8, 107, '2025-08-08', 'completed', NULL, 'uploads/1754627699_20250808_095925.jpg', 'Panen', '2025-08-08 11:35:00', NULL, 8, NULL),
(170, 6, 137, '2025-08-11', 'completed', NULL, 'uploads/1754885074_IMG_1487.jpeg', NULL, '2025-08-11 11:04:35', '2025-10-10 10:34:35', 6, 6),
(171, 6, 138, '2025-08-11', 'completed', NULL, 'uploads/1754885393_IMG_1489.jpeg', NULL, '2025-08-11 11:09:53', '2025-10-10 10:34:58', 6, 6),
(172, 8, 97, '2025-08-11', 'satisfactory', NULL, 'uploads/1754889543_IMG-20250811-WA0014.jpg', NULL, '2025-08-11 12:19:04', NULL, 8, NULL),
(173, 8, 139, '2025-08-11', 'satisfactory', NULL, 'uploads/1754889864_IMG-20250811-WA0012.jpg', NULL, '2025-08-11 12:24:25', NULL, 8, NULL),
(174, 7, 47, '2025-08-11', 'satisfactory', NULL, 'uploads/1754890325_1000490594.jpg', NULL, '2025-08-11 12:32:05', NULL, 7, NULL),
(175, 7, 68, '2025-08-11', 'satisfactory', NULL, 'uploads/1754895012_1000490768.jpg', NULL, '2025-08-11 13:50:12', NULL, 7, NULL),
(176, 8, 12, '2025-08-11', 'satisfactory', NULL, 'uploads/1754896857_PhotoGrid_Plus_1754896594919.jpg', NULL, '2025-08-11 14:20:57', NULL, 8, NULL),
(177, 8, 141, '2025-08-12', 'satisfactory', NULL, 'uploads/1754970806_20250812_104945.jpg', NULL, '2025-08-12 10:53:26', NULL, 8, NULL),
(178, 5, 39, '2025-08-12', 'completed', '-6.7616377,108.4904798', 'uploads/1754983790_IMG20250812135020.jpg', 'Posisi jagung madu dan jagung Lilac sudah dipanen namundipanen bertahap', '2025-08-12 14:29:50', '2025-08-15 07:37:46', 5, 5),
(179, 5, 83, '2025-08-12', 'satisfactory', NULL, 'uploads/1754983843_IMG20250812133746_01.jpg', 'Alhamdulillah tanaman optimal namun pertumbuhan siwil ditanaman lumayan banyak', '2025-08-12 14:30:44', NULL, 5, NULL),
(180, 6, 19, '2025-08-12', 'satisfactory', NULL, 'uploads/1754984518_IMG_1531.jpeg', NULL, '2025-08-12 14:41:58', NULL, 6, NULL),
(181, 5, 37, '2025-08-12', 'completed', '-6.6916609,108.4993834', 'uploads/1755005769_IMG20250812151541.jpg', 'Panen Lilac respon petani merasa diuntungkan karena eceran laku dengan cepat. Bagi pelanggan juga merasa puas karena tongkol besar serta warna pekat. Ada opsi masukan digarap yang warna putih danwarna batik', '2025-08-12 20:36:09', NULL, 5, NULL),
(182, 8, 14, '2025-08-12', 'completed', NULL, 'uploads/1755005830_20250723_130247.jpg', NULL, '2025-08-12 20:37:11', NULL, 8, NULL),
(183, 5, 38, '2025-08-12', 'completed', '-6.6916609,108.4993834', 'uploads/1755005879_IMG20250812151344.jpg', 'Posisi tanaman saat menjelang panen terserang kresek daun,hal ini karena faktor ujan 2 hari dan membuat tanaman terlihat kresek', '2025-08-12 20:38:00', '2025-08-15 07:37:18', 5, 5),
(184, 5, 56, '2025-08-11', 'satisfactory', '-6.6916609,108.4993834', 'uploads/1755005985_IMG20250811122808_01.jpg', 'Untuk saat ini tanaman masih belum terkendala namun sebagian pas dicek siang hari pada layu', '2025-08-12 20:39:45', NULL, 5, NULL),
(185, 5, 35, '2025-08-12', 'failed', '-6.6916609,108.4993834', 'uploads/1755006176_IMG-20250810-WA0020.jpg', 'Menjelang panen tanaman kekurangan air sehingga pada kerompang', '2025-08-12 20:42:56', '2025-08-28 21:41:07', 5, 5),
(186, 5, 136, '2025-08-08', 'satisfactory', '-6.6916609,108.4993834', 'uploads/1755006436_IMG20250808154226.jpg', 'Tanaman ditanam sistim tumpangsari dengan tanaman kacang. Untuk performa DB 90% tumbuh optimal', '2025-08-12 20:47:17', NULL, 5, NULL),
(187, 5, 39, '2025-08-12', 'completed', NULL, 'uploads/1755006594_IMG20250812151117.jpg', 'Proses panenan lilac terahir diecer Alhamdulillah pengecer rebusan langsng banyak yang minat dijagung lilac', '2025-08-12 20:49:54', NULL, 5, NULL),
(188, 5, 39, '2025-08-12', 'completed', '-6.6916609,108.4993834', 'uploads/1755006704_IMG20250812151116.jpg', 'Posisi sedang dipanen namun bertahap karena untuk stok binaan pengecernya', '2025-08-12 20:51:44', NULL, 5, NULL),
(189, 5, 39, '2025-08-12', 'completed', '-6.6916609,108.4993834', 'uploads/1755006850_IMG20250812151116_01.jpg', 'Jagung madu dilahan tersebut Sedang dipanen bertahap', '2025-08-12 20:54:11', NULL, 5, NULL),
(190, 5, 81, '2025-08-12', 'completed', '-6.6916609,108.4993834', 'uploads/1755006945_IMG20250812151116_01.jpg', 'Jagung madu yang sudah tua Dipanen bertahap', '2025-08-12 20:55:45', '2025-08-15 07:41:01', 5, 5),
(191, 5, 119, '2025-08-12', 'satisfactory', '-6.6916609,108.4993834', 'uploads/1755007139_IMG20250812144323_BURST001.jpg', 'Pertumbuhan serempakdan respon petani lebih cocok ke Reva mengenai daya tumbuh dibanding madu', '2025-08-12 20:58:59', NULL, 5, NULL),
(192, 5, 128, '2025-08-08', 'satisfactory', NULL, 'uploads/1755007246_Picsart_25-08-08_10-58-32-397.jpg', NULL, '2025-08-12 21:00:47', NULL, 5, NULL),
(193, 5, 82, '2025-08-12', 'satisfactory', '-6.6916609,108.4993834', 'uploads/1755007333_IMG20250812145448.jpg', NULL, '2025-08-12 21:02:14', NULL, 5, NULL),
(194, 5, 126, '2025-08-08', 'not_yet_evaluated', '-6.6898461,108.4967865', 'uploads/1755007600_Screenshot_2025-08-12-21-06-24-31_40deb401b9ffe8e1df2f1cc5ba480b12.jpg', 'Tanaman terendam banjir DB kurang optimal', '2025-08-12 21:06:40', '2025-08-12 21:33:00', 5, 5),
(195, 5, 143, '2025-08-11', 'not_yet_planted', '-6.6916609,108.4993834', 'uploads/1755009373_IMG20250811124805.jpg', 'Diskusi dan atur jadwal tanam jagung Lilac dipabedilan. Sambil menunggu binaannya dan dilist untuk kebutuhan benihnya', '2025-08-12 21:36:14', '2025-08-12 21:36:22', 5, 5),
(196, 8, 114, '2025-08-13', 'satisfactory', NULL, 'uploads/1755062437_PhotoGrid_Plus_1755062365677.jpg', 'Siwil lumayan banyak, kondisi pertumbuhan normal', '2025-08-13 12:20:38', NULL, 8, NULL),
(197, 8, 144, '2025-08-13', 'satisfactory', NULL, 'uploads/1755063470_PhotoGrid_Plus_1755063148424.jpg', 'Terkena serangan ulat', '2025-08-13 12:37:50', NULL, 8, NULL),
(198, 6, 120, '2025-08-14', 'satisfactory', NULL, 'uploads/1755155191_IMG_1616.jpeg', NULL, '2025-08-14 14:06:31', NULL, 6, NULL),
(199, 6, 18, '2025-08-14', 'satisfactory', NULL, 'uploads/1755155301_IMG_1621.jpeg', NULL, '2025-08-14 14:08:21', NULL, 6, NULL),
(200, 5, 145, '2025-08-14', 'not_yet_evaluated', '-6.6913417,108.4993834', 'uploads/1755217909_IMG20250814113317.jpg', 'Proses penanaman trial l7', '2025-08-15 07:31:49', NULL, 5, NULL),
(201, 5, 146, '2025-08-15', 'not_yet_planted', NULL, 'uploads/1755218076_IMG20250814134035.jpg', 'Pemberian sample demplot jagung h72 sekaligus persiapan lahan dan rencana penanaman hari Mingguini', '2025-08-15 07:34:36', NULL, 5, NULL),
(202, 5, 64, '2025-08-14', 'satisfactory', NULL, 'uploads/1755218359_IMG20250814144754.jpg', 'Update tanaman mulai terserah ulat', '2025-08-15 07:39:19', NULL, 5, NULL),
(203, 5, 136, '2025-08-12', 'satisfactory', NULL, 'uploads/1755218531_IMG-20250814-WA0069.jpg', 'Penanganan hama ulat', '2025-08-15 07:42:11', NULL, 5, NULL),
(204, 5, 48, '2025-08-11', 'completed', NULL, 'uploads/1755218709_IMG20250811102539.jpg', 'Proses panenjagung dilahan mas hadi', '2025-08-15 07:45:09', NULL, 5, NULL),
(205, 5, 125, '2025-08-14', 'satisfactory', NULL, 'uploads/1755219045_Screenshot_2025-08-15-07-50-23-38_86d1cf8180063029dcfbc18385c9fce5.jpg', NULL, '2025-08-15 07:50:45', NULL, 5, NULL),
(206, 6, 148, '2025-08-15', 'satisfactory', NULL, 'uploads/1755255829_1755255655564.jpg', NULL, '2025-08-15 18:03:49', NULL, 6, NULL),
(207, 7, 140, '2025-08-15', 'satisfactory', NULL, 'uploads/1755265337_1000490593.jpg', NULL, '2025-08-15 20:42:17', NULL, 7, NULL),
(208, 8, 142, '2025-08-19', 'satisfactory', NULL, 'uploads/1755580364_20250819_120751.jpg', NULL, '2025-08-19 12:12:45', NULL, 8, NULL),
(209, 8, 12, '2025-08-19', 'satisfactory', NULL, 'uploads/1755588454_PhotoGrid_Plus_1755588297527.jpg', NULL, '2025-08-19 14:27:34', NULL, 8, NULL),
(210, 8, 135, '2025-08-19', 'completed', NULL, 'uploads/1755590295_PhotoGrid_Plus_1755590203770.jpg', NULL, '2025-08-19 14:58:15', '2025-10-02 07:25:41', 8, 8),
(211, 8, 85, '2025-08-19', 'unsatisfactory', NULL, 'uploads/1755593480_PhotoGrid_Plus_1755593284561.jpg', 'DB 50%', '2025-08-19 15:51:20', NULL, 8, NULL),
(212, 7, 131, '2025-08-20', 'failed', NULL, 'uploads/1755661051_1000503264.jpg', 'Terkena banjir tanggul jebol', '2025-08-20 10:37:32', NULL, 7, NULL),
(213, 7, 129, '2025-08-20', 'failed', NULL, 'uploads/1755661109_1000503264.jpg', 'Terkena banjir tanggul jebol', '2025-08-20 10:38:30', NULL, 7, NULL),
(214, 7, 80, '2025-08-20', 'completed', NULL, 'uploads/1755661323_1000503275.jpg', 'Petikan ke 20', '2025-08-20 10:42:03', NULL, 7, NULL),
(215, 8, 114, '2025-08-20', 'satisfactory', NULL, 'uploads/1755666354_PhotoGrid_Plus_1755666081352.jpg', 'Terkena serangan hawar daun dan siwil muncul +-80%', '2025-08-20 12:05:54', NULL, 8, NULL),
(216, 8, 144, '2025-08-20', 'satisfactory', NULL, 'uploads/1755666427_PhotoGrid_Plus_1755666117305.jpg', 'Terkena serangan ulat +-30%', '2025-08-20 12:07:07', NULL, 8, NULL),
(217, 6, 19, '2025-08-20', 'satisfactory', NULL, 'uploads/1755733726_IMG_1800.jpeg', NULL, '2025-08-21 06:48:46', NULL, 6, NULL),
(218, 6, 132, '2025-08-20', 'satisfactory', NULL, 'uploads/1755733859_IMG_1807.jpeg', NULL, '2025-08-21 06:50:59', NULL, 6, NULL),
(219, 7, 68, '2025-08-21', 'satisfactory', NULL, 'uploads/1755739382_1000504601.jpg', NULL, '2025-08-21 08:23:02', NULL, 7, NULL),
(220, 5, 145, '2025-08-19', 'satisfactory', '-6.8506168,108.6473807', 'uploads/1755740876_IMG20250819151225.jpg', 'Tanaman masih belum tumbuh total', '2025-08-21 08:47:57', NULL, 5, NULL),
(221, 5, 82, '2025-08-20', 'satisfactory', '-6.8506112,108.6473814', 'uploads/1755740991_Picsart_25-08-20_13-20-04-495.jpg', 'Posisi tanaman sudah mulai mendekati mutren', '2025-08-21 08:49:52', '2025-08-21 08:52:21', 5, 5),
(222, 5, 125, '2025-08-21', 'satisfactory', NULL, 'uploads/1755741335_IMG_20250821_085509.jpg', NULL, '2025-08-21 08:55:35', NULL, 5, NULL),
(223, 5, 136, '2025-08-21', 'satisfactory', NULL, 'uploads/1755741408_Picsart_25-08-20_16-12-14-297.jpg', 'Tanaman tumbuh optimal namun rumput terlalu cepat pertumbuhannya', '2025-08-21 08:56:48', NULL, 5, NULL),
(224, 5, 64, '2025-08-21', 'satisfactory', NULL, 'uploads/1755741507_IMG20250819162536.jpg', 'Tanaman tumbuh optimal namun gejala serangan hama ulat sudah mulai masuk', '2025-08-21 08:58:27', NULL, 5, NULL),
(225, 5, 119, '2025-08-20', 'satisfactory', '-6.8506144,108.6473799', 'uploads/1755741689_IMG20250820131528.jpg', NULL, '2025-08-21 09:01:29', NULL, 5, NULL),
(226, 5, 56, '2025-08-21', 'satisfactory', NULL, 'uploads/1755741813_IMG20250819141320.jpg', NULL, '2025-08-21 09:03:33', NULL, 5, NULL),
(227, 5, 83, '2025-08-20', 'satisfactory', NULL, 'uploads/1755741884_IMG20250820124218.jpg', NULL, '2025-08-21 09:04:45', NULL, 5, NULL),
(228, 5, 113, '2025-08-20', 'satisfactory', '-6.8506173,108.6473803', 'uploads/1755741981_Screenshot_2025-08-21-09-06-11-37_40deb401b9ffe8e1df2f1cc5ba480b12.jpg', NULL, '2025-08-21 09:06:22', NULL, 5, NULL),
(229, 5, 28, '2025-08-14', 'satisfactory', NULL, 'uploads/1755742124_IMG20250815131649.jpg', NULL, '2025-08-21 09:08:44', NULL, 5, NULL),
(230, 5, 29, '2025-08-14', 'satisfactory', NULL, 'uploads/1755742242_IMG20250815131634.jpg', NULL, '2025-08-21 09:10:43', NULL, 5, NULL),
(231, 8, 155, '2025-08-21', 'unsatisfactory', NULL, 'uploads/1755749336_PhotoGrid_Plus_1755749221170.jpg', 'Pertumbuhan kurang maksimal karna sempat kekeringan', '2025-08-21 11:08:56', '2025-09-10 17:45:10', 8, 8),
(232, 11, 156, '2025-08-21', 'satisfactory', '-6.850405,107.2550867', 'uploads/1755761918_IMG_20250821_132058_777.jpg', 'Lavantadengan Umur (±) 20 Hst Kepimilikan Pa Nandar Cukup Memuaskan Hanya Saja Telat Memberi Tali atw Penalian Agar Tanaman Menyangga Selernya', '2025-08-21 14:38:39', NULL, 11, NULL),
(233, 6, 71, '2025-08-21', 'satisfactory', NULL, 'uploads/1755765644_64b0b3bb-7692-45c7-8ed5-8b4077a5659f.jpeg', NULL, '2025-08-21 15:40:44', NULL, 6, NULL),
(234, 6, 18, '2025-08-21', 'satisfactory', NULL, 'uploads/1755765824_IMG_1768.jpeg', NULL, '2025-08-21 15:43:44', NULL, 6, NULL),
(235, 6, 74, '2025-08-13', 'completed', NULL, 'uploads/1755765980_IMG_1585.jpeg', NULL, '2025-08-21 15:46:20', '2025-10-10 10:35:33', 6, 6),
(236, 6, 72, '2025-08-13', 'satisfactory', NULL, 'uploads/1755766097_IMG_1549.jpeg', NULL, '2025-08-21 15:48:18', NULL, 6, NULL),
(237, 6, 120, '2025-08-21', 'satisfactory', NULL, 'uploads/1755766191_IMG_1778.jpeg', NULL, '2025-08-21 15:49:51', NULL, 6, NULL),
(238, 8, 157, '2025-08-21', 'completed', NULL, 'uploads/1755768633_PhotoGrid_Plus_1755768366828.jpg', NULL, '2025-08-21 16:30:33', '2026-01-21 15:22:30', 8, 8),
(239, 6, 122, '2025-08-21', 'satisfactory', NULL, 'uploads/1755771260_IMG-20250821-WA0013.jpg', NULL, '2025-08-21 17:14:20', NULL, 6, NULL),
(240, 6, 127, '2025-08-22', 'satisfactory', NULL, 'uploads/1755827182_IMG_1854.jpeg', NULL, '2025-08-22 08:46:22', NULL, 6, NULL),
(241, 6, 111, '2025-08-22', 'completed', NULL, 'uploads/1755832509_IMG_1861.jpeg', NULL, '2025-08-22 10:15:10', '2025-12-05 21:20:45', 6, 6),
(242, 6, 158, '2025-08-22', 'satisfactory', NULL, 'uploads/1755832728_IMG_1883.jpeg', NULL, '2025-08-22 10:18:49', NULL, 6, NULL),
(243, 7, 47, '2025-08-22', 'satisfactory', NULL, 'uploads/1755832989_1000506258.jpg', NULL, '2025-08-22 10:23:10', NULL, 7, NULL),
(244, 7, 140, '2025-08-22', 'satisfactory', NULL, 'uploads/1755834707_1000506294.jpg', NULL, '2025-08-22 10:51:47', NULL, 7, NULL),
(245, 7, 84, '2025-08-22', 'satisfactory', NULL, 'uploads/1755836108_1000506295.jpg', NULL, '2025-08-22 11:15:09', NULL, 7, NULL),
(246, 5, 60, '2025-08-22', 'satisfactory', NULL, 'uploads/1755841594_Picsart_25-08-22_10-58-50-544.jpg', NULL, '2025-08-22 12:46:35', NULL, 5, NULL),
(247, 5, 59, '2025-08-22', 'satisfactory', NULL, 'uploads/1755841711_IMG20250822095249.jpg', 'Proses penanaman jagung lilac', '2025-08-22 12:48:31', NULL, 5, NULL),
(248, 5, 126, '2025-08-22', 'satisfactory', NULL, 'uploads/1755841782_IMG20250822103235.jpg', 'Tanaman Lilac masih terselamatkan namun rumputnya terlalu banyak', '2025-08-22 12:49:43', NULL, 5, NULL),
(249, 5, 128, '2025-08-22', 'satisfactory', NULL, 'uploads/1755841924_Screenshot_2025-08-22-12-51-46-34_40deb401b9ffe8e1df2f1cc5ba480b12.jpg', 'Alhamdulillah pertumbuhan optimal walaupun terendam banjir', '2025-08-22 12:52:04', NULL, 5, NULL),
(250, 5, 58, '2025-08-22', 'satisfactory', NULL, 'uploads/1755842097_IMG20250820131530.jpg', NULL, '2025-08-22 12:54:57', NULL, 5, NULL),
(251, 8, 139, '2025-08-22', 'satisfactory', NULL, 'uploads/1755853227_PhotoGrid_Plus_1755851961317.jpg', NULL, '2025-08-22 16:00:27', NULL, 8, NULL),
(252, 8, 97, '2025-08-22', 'satisfactory', NULL, 'uploads/1755853294_PhotoGrid_Plus_1755851793229.jpg', NULL, '2025-08-22 16:01:35', NULL, 8, NULL),
(253, 8, 159, '2025-08-22', 'satisfactory', NULL, 'uploads/1755853371_PhotoGrid_Plus_1755851741466.jpg', NULL, '2025-08-22 16:02:51', NULL, 8, NULL),
(254, 6, 42, '2025-08-22', 'satisfactory', NULL, 'uploads/1756042573_IMG_1943.jpeg', NULL, '2025-08-24 20:36:13', NULL, 6, NULL),
(255, 6, 45, '2025-08-22', 'completed', NULL, 'uploads/1756042775_IMG_1904.jpeg', NULL, '2025-08-24 20:39:35', '2025-10-10 10:32:43', 6, 6),
(256, 6, 44, '2025-08-22', 'failed', NULL, 'uploads/1756042917_IMG_1903.jpeg', NULL, '2025-08-24 20:41:57', '2025-10-30 21:26:30', 6, 6),
(257, 6, 46, '2025-08-22', 'completed', NULL, 'uploads/1756043118_IMG_1902.jpeg', NULL, '2025-08-24 20:45:18', '2025-10-10 10:38:53', 6, 6),
(258, 6, 43, '2025-08-22', 'completed', NULL, 'uploads/1756043317_IMG_1899.jpeg', NULL, '2025-08-24 20:48:37', '2025-10-10 10:37:54', 6, 6),
(259, 7, 124, '2025-08-26', 'satisfactory', NULL, 'uploads/1756176097_1000511052.jpg', NULL, '2025-08-26 09:41:37', NULL, 7, NULL),
(260, 7, 66, '2025-08-26', 'completed', NULL, 'uploads/1756176158_1000510982.jpg', NULL, '2025-08-26 09:42:38', NULL, 7, NULL),
(261, 7, 66, '2025-08-26', 'satisfactory', NULL, 'uploads/1756176199_1000511059.jpg', NULL, '2025-08-26 09:43:19', NULL, 7, NULL),
(262, 6, 71, '2025-08-26', 'satisfactory', NULL, 'uploads/1756176935_b7060f22-41c3-4d51-a7c3-0649aef32cd0.jpeg', NULL, '2025-08-26 09:55:35', NULL, 6, NULL),
(263, 8, 147, '2025-08-26', 'satisfactory', NULL, 'uploads/1756188368_20250826_123003.jpg', NULL, '2025-08-26 13:06:09', NULL, 8, NULL),
(264, 8, 141, '2025-08-26', 'satisfactory', NULL, 'uploads/1756188435_PhotoGrid_Plus_1756183529089.jpg', NULL, '2025-08-26 13:07:15', NULL, 8, NULL),
(265, 11, 160, '2025-07-29', 'satisfactory', '-6.8304621,107.1683609', 'uploads/1756254198_IMG-20250729-WA0036.jpg', '±10 Hst', '2025-08-27 07:23:18', '2025-08-27 07:24:12', 11, 11),
(266, 6, 19, '2025-08-27', 'satisfactory', NULL, 'uploads/1756261584_IMG_2142.jpeg', NULL, '2025-08-27 09:26:24', NULL, 6, NULL),
(267, 6, 161, '2025-09-22', 'completed', NULL, 'uploads/1758531708_IMG_2973.jpeg', NULL, '2025-08-27 09:31:40', '2025-10-17 21:17:13', 6, 6),
(268, 6, 162, '2025-08-27', 'satisfactory', NULL, 'uploads/1756262011_IMG_2138.jpeg', NULL, '2025-08-27 09:33:31', NULL, 6, NULL),
(269, 6, 163, '2025-08-27', 'satisfactory', NULL, 'uploads/1756262329_99925472-ea56-49ee-a375-ed54ffac8144.jpeg', NULL, '2025-08-27 09:38:49', NULL, 6, NULL),
(270, 6, 164, '2025-08-27', 'satisfactory', NULL, 'uploads/1756262670_cfbe21f8-7f76-45a4-a0b3-1868b5378573.jpeg', NULL, '2025-08-27 09:44:30', NULL, 6, NULL),
(271, 6, 165, '2025-08-27', 'satisfactory', NULL, 'uploads/1756262927_IMG_2128.jpeg', NULL, '2025-08-27 09:48:48', NULL, 6, NULL),
(272, 6, 166, '2025-08-27', 'satisfactory', NULL, 'uploads/1756263202_IMG_2131.jpeg', NULL, '2025-08-27 09:53:23', NULL, 6, NULL),
(273, 5, 64, '2025-08-27', 'satisfactory', NULL, 'uploads/1756264572_Picsart_25-08-26_14-22-27-528.jpg', 'Tanaman tumbuh dengan optimal, sedang dilakukan proses pembumbunan supaya penyerapan unsur hara maksimal', '2025-08-27 10:16:12', NULL, 5, NULL),
(274, 5, 113, '2025-08-27', 'satisfactory', NULL, 'uploads/1756264652_Picsart_25-08-26_14-21-42-678.jpg', 'Sedang dilakukan pemupukan susulan ke 2 dan pembumbunan lahan', '2025-08-27 10:17:32', NULL, 5, NULL),
(275, 5, 125, '2025-08-27', 'satisfactory', NULL, 'uploads/1756265229_Screenshot_2025-08-27-10-26-44-88_40deb401b9ffe8e1df2f1cc5ba480b12.jpg', 'Terdapat tanaman yang tidak tumbuh sebanyak 27 pohon dan terserang ulat 17 pohon', '2025-08-27 10:27:09', '2025-08-27 10:27:52', 5, 5),
(276, 8, 12, '2025-08-27', 'satisfactory', NULL, 'uploads/1756265581_PhotoGrid_Plus_1756265493918.jpg', NULL, '2025-08-27 10:33:01', NULL, 8, NULL),
(277, 5, 55, '2025-08-27', 'satisfactory', NULL, 'uploads/1756265912_IMG20250826145156.jpg', 'Cek perkembangan tanaman jagung Reva dan melihat hasil buah jagung jagung Reva dilahan pak Tarkim di jatirenggang Cirebon', '2025-08-27 10:38:33', NULL, 5, NULL),
(278, 5, 57, '2025-08-26', 'satisfactory', NULL, 'uploads/1756266114_Screenshot_2025-08-27-10-41-45-91_40deb401b9ffe8e1df2f1cc5ba480b12.jpg', 'Kawal perkembangan jagung Reva dilahan pak Udin cikulak jati renggang', '2025-08-27 10:41:54', NULL, 5, NULL),
(279, 5, 146, '2025-08-28', 'satisfactory', NULL, 'uploads/1756391218_Screenshot_2025-08-28-21-26-40-63_40deb401b9ffe8e1df2f1cc5ba480b12.jpg', 'Benih baru mulai pada tumbuh', '2025-08-28 21:26:58', NULL, 5, NULL),
(280, 5, 60, '2025-08-28', 'satisfactory', NULL, 'uploads/1756391271_IMG20250827112008.jpg', 'Buah yang ditanam dipinggir ada yang sudah tua namun sedikit. Dan kebanyakan masih muda', '2025-08-28 21:27:52', '2025-08-28 21:28:42', 5, 5),
(281, 5, 145, '2025-08-28', 'unsatisfactory', NULL, 'uploads/1756391504_Screenshot_2025-08-28-21-31-33-53_40deb401b9ffe8e1df2f1cc5ba480b12.jpg', 'Benih tumbuh 60% posisi tanaman terguyur hujan dan suhu terlalu panas namun exotic bisa tahan dan DB masih bagus', '2025-08-28 21:31:45', '2025-09-09 19:08:21', 5, 5),
(282, 5, 59, '2025-08-28', 'satisfactory', NULL, 'uploads/1756391620_IMG20250827111225.jpg', NULL, '2025-08-28 21:33:40', NULL, 5, NULL),
(283, 5, 128, '2025-08-28', 'satisfactory', NULL, 'uploads/1756391691_Picsart_25-08-27_13-31-17-508.jpg', 'Tanaman tumbuh optimal namun posisi saat ini sedang kekurangan air', '2025-08-28 21:34:52', NULL, 5, NULL);
INSERT INTO `demo_plot_visits` (`id`, `user_id`, `demo_plot_id`, `visit_date`, `plant_status`, `latlong`, `image_path`, `notes`, `created_datetime`, `updated_datetime`, `created_by_uid`, `updated_by_uid`) VALUES
(284, 5, 83, '2025-08-28', 'satisfactory', NULL, 'uploads/1756391763_IMG-20250826-WA0023.jpg', 'Sedang dipanen bertahap untuk binaan pengecer ditalun', '2025-08-28 21:36:03', NULL, 5, NULL),
(285, 8, 114, '2025-08-29', 'completed', NULL, 'uploads/1756432962_20250829_090118.jpg', NULL, '2025-08-29 09:02:42', NULL, 8, NULL),
(286, 7, 170, '2025-08-30', 'satisfactory', NULL, 'uploads/1756524602_1000517254.jpg', NULL, '2025-08-30 10:30:02', NULL, 7, NULL),
(287, 7, 153, '2025-08-30', 'satisfactory', NULL, 'uploads/1756526776_1000517288.jpg', NULL, '2025-08-30 11:06:16', NULL, 7, NULL),
(288, 7, 173, '2025-08-30', 'satisfactory', NULL, 'uploads/1756527387_1000517254.jpg', NULL, '2025-08-30 11:16:28', NULL, 7, NULL),
(289, 7, 171, '2025-08-31', 'satisfactory', NULL, 'uploads/1756646913_1000517289.jpg', NULL, '2025-08-31 20:28:33', NULL, 7, NULL),
(290, 7, 47, '2025-08-31', 'satisfactory', NULL, 'uploads/1756647704_1000518951.jpg', NULL, '2025-08-31 20:41:45', NULL, 7, NULL),
(291, 7, 84, '2025-08-31', 'satisfactory', NULL, 'uploads/1756647846_1000518952.jpg', NULL, '2025-08-31 20:44:06', NULL, 7, NULL),
(292, 7, 68, '2025-08-31', 'satisfactory', NULL, 'uploads/1756648059_1000518959.jpg', NULL, '2025-08-31 20:47:39', NULL, 7, NULL),
(293, 7, 67, '2025-09-01', 'satisfactory', NULL, 'uploads/1756688741_1000519177.jpg', NULL, '2025-09-01 08:05:42', NULL, 7, NULL),
(294, 6, 132, '2025-09-01', 'unsatisfactory', NULL, 'uploads/1756701239_IMG_2355.jpeg', NULL, '2025-09-01 11:33:59', NULL, 6, NULL),
(295, 8, 12, '2025-09-01', 'satisfactory', NULL, 'uploads/1756704237_PhotoGrid_Plus_1756704181617.jpg', NULL, '2025-09-01 12:23:57', NULL, 8, NULL),
(296, 5, 55, '2025-09-01', 'completed', NULL, 'uploads/1756704839_IMG20250901090317.jpg', 'Alhmdulillah hasil panenan memuaskan dan langsng order tanam kembali namun jagung madu karena stok jagungRevatidak ada', '2025-09-01 12:33:59', NULL, 5, NULL),
(297, 8, 142, '2025-09-01', 'satisfactory', NULL, 'uploads/1756709390_PhotoGrid_Plus_1756709209533.jpg', NULL, '2025-09-01 13:49:50', NULL, 8, NULL),
(298, 6, 174, '2025-09-01', 'completed', NULL, 'uploads/1756711007_IMG_2091.jpeg', NULL, '2025-09-01 14:16:47', '2025-10-10 10:32:10', 6, 6),
(299, 8, 139, '2025-09-01', 'satisfactory', NULL, 'uploads/1756712778_PhotoGrid_Plus_1756712454418.jpg', NULL, '2025-09-01 14:46:18', NULL, 8, NULL),
(300, 8, 159, '2025-09-01', 'satisfactory', NULL, 'uploads/1756712865_PhotoGrid_Plus_1756712422872.jpg', NULL, '2025-09-01 14:47:45', NULL, 8, NULL),
(301, 8, 97, '2025-09-01', 'satisfactory', NULL, 'uploads/1756712927_PhotoGrid_Plus_1756712487598.jpg', NULL, '2025-09-01 14:48:47', NULL, 8, NULL),
(302, 8, 12, '2025-09-03', 'completed', NULL, 'uploads/1756881947_20250903_123858.jpg', NULL, '2025-09-03 13:45:48', NULL, 8, NULL),
(303, 6, 175, '2025-09-03', 'satisfactory', NULL, 'uploads/1756886832_IMG_2385.jpeg', NULL, '2025-09-03 15:07:13', NULL, 6, NULL),
(304, 6, 176, '2025-09-03', 'completed', NULL, 'uploads/1756886988_IMG_2384.jpeg', NULL, '2025-09-03 15:09:48', '2025-12-05 21:22:06', 6, 6),
(305, 6, 18, '2025-09-03', 'satisfactory', NULL, 'uploads/1756887045_IMG_2370.jpeg', NULL, '2025-09-03 15:10:45', NULL, 6, NULL),
(306, 6, 120, '2025-09-03', 'satisfactory', NULL, 'uploads/1756887108_IMG_2368.jpeg', NULL, '2025-09-03 15:11:48', NULL, 6, NULL),
(307, 6, 134, '2025-09-03', 'satisfactory', NULL, 'uploads/1756887204_IMG_2362.jpeg', NULL, '2025-09-03 15:13:24', NULL, 6, NULL),
(308, 6, 133, '2025-09-03', 'completed', NULL, 'uploads/1756887294_IMG_2361.jpeg', 'Tercampur exotic', '2025-09-03 15:14:55', '2025-09-24 18:20:07', 6, 6),
(309, 7, 149, '2025-09-03', 'satisfactory', NULL, 'uploads/1756891228_1000522832.jpg', NULL, '2025-09-03 16:20:28', NULL, 7, NULL),
(310, 7, 177, '2025-09-03', 'satisfactory', NULL, 'uploads/1756891910_1000522840.jpg', NULL, '2025-09-03 16:31:50', NULL, 7, NULL),
(311, 7, 179, '2025-09-03', 'satisfactory', NULL, 'uploads/1756892566_1000522850.jpg', NULL, '2025-09-03 16:42:46', NULL, 7, NULL),
(312, 5, 28, '2025-09-04', 'completed', '-6.871657,108.7820835', 'uploads/1756956400_IMG20250903123623.jpg', 'Sudah panen dan ditanami Lilac kembali 5', '2025-09-04 10:26:41', NULL, 5, NULL),
(313, 7, 47, '2025-09-04', 'satisfactory', NULL, 'uploads/1756971644_1000524101.jpg', NULL, '2025-09-04 14:40:44', NULL, 7, NULL),
(314, 7, 84, '2025-09-04', 'satisfactory', NULL, 'uploads/1756971797_1000524278.jpg', NULL, '2025-09-04 14:43:17', NULL, 7, NULL),
(315, 7, 140, '2025-09-04', 'satisfactory', NULL, 'uploads/1756971823_1000524279.jpg', NULL, '2025-09-04 14:43:43', NULL, 7, NULL),
(316, 5, 143, '2025-09-04', 'satisfactory', '-6.8805142,108.7293233', 'uploads/1756971831_Screenshot_2025-09-04-14-43-36-92_40deb401b9ffe8e1df2f1cc5ba480b12.jpg', 'Tanaman Lilac Alhamdulillah tumbuh serempak. Kompetitor merk arumba dan rasanya DB sedang mengalami kendala', '2025-09-04 14:43:52', NULL, 5, NULL),
(317, 7, 68, '2025-09-04', 'satisfactory', NULL, 'uploads/1756971915_1000524280.jpg', NULL, '2025-09-04 14:45:15', NULL, 7, NULL),
(318, 5, 83, '2025-09-04', 'completed', '-6.6928811,108.4978014', 'uploads/1756988228_IMG20250830130143.jpg', 'Sudah dipanen total secara pembukuan rata-rata perbungkus dapat 4,5 kwintal dikarenakan terdapat spot yang terkena tikus', '2025-09-04 19:17:08', '2025-09-04 19:51:57', 5, 5),
(319, 5, 60, '2025-09-04', 'satisfactory', '-6.6926692,108.4970191', 'uploads/1756988516_IMG20250827112037.jpg', 'Atur jadwal dipanen mulai hari Jumat diecer sendiri', '2025-09-04 19:21:56', NULL, 5, NULL),
(320, 5, 146, '2025-09-04', 'unsatisfactory', '-6.6926692,108.4970191', 'uploads/1756988764_IMG20250904131832.jpg', 'Tanaman jagung h72 trial,Reva, madu,exotic dan perbandingan kompetitor merk mabes DB jelek karena waktu penanaman diguyur hujan 2 hari berturut-turut.DB smuanya kalah dan akan ditanam ulang', '2025-09-04 19:26:05', NULL, 5, NULL),
(321, 5, 125, '2025-09-01', 'satisfactory', '-6.6926692,108.4970191', 'uploads/1756988969_IMG20250902135052.jpg', 'Tanaman tumbuh optimal kondisi saat ini sedang musim panas dan hama ulat pada bertelur dan menetas dan terpantau beberapa tanaman sudah terkena serangan ulat', '2025-09-04 19:29:29', NULL, 5, NULL),
(322, 5, 113, '2025-09-01', 'satisfactory', NULL, 'uploads/1756989158_IMG20250902134634.jpg', 'Tanaman terkondisikan,sedang dilakukan pembumbunan dan penyemprotan obat emacek untuk pencegahan ulat dilahan tersebu', '2025-09-04 19:32:38', NULL, 5, NULL),
(323, 5, 64, '2025-09-01', 'satisfactory', '-6.6926692,108.4970191', 'uploads/1756989279_IMG20250902134653.jpg', 'Terdapat temuan salah satu tanaman yang terkena bulai dan ada beberapa yang terserah hama lalat bibit sehingga tanaman melungkar mengkerut', '2025-09-04 19:34:39', NULL, 5, NULL),
(324, 5, 58, '2025-09-04', 'satisfactory', '-6.6926692,108.4970191', 'uploads/1756989399_Screenshot_2025-09-04-19-36-28-06_40deb401b9ffe8e1df2f1cc5ba480b12.jpg', 'Tanaman terendam air sebagian tumbuh melambat dan ada beberapabaris yang DB nya tidak full', '2025-09-04 19:36:40', NULL, 5, NULL),
(325, 5, 136, '2025-09-04', 'satisfactory', '-6.6926692,108.4970191', 'uploads/1756989509_IMG-20250903-WA0039.jpg', 'Tanaman tumbuh dengan optimal ada beberapa tanaman yang terkena moler serangan lalat bibit', '2025-09-04 19:38:29', NULL, 5, NULL),
(326, 5, 119, '2025-09-04', 'satisfactory', '-6.6926692,108.4970191', 'uploads/1756989621_IMG20250904163156.jpg', 'Alhamdulillah tanaman terkondisikan tumbuh optimal dan serempak\r\n Namun serangan ulat sudah mulai menyerang 21 tanaman dan disemprot emacel untuk antisipasi supaya tidak menyebar', '2025-09-04 19:40:22', NULL, 5, NULL),
(327, 5, 29, '2025-09-04', 'completed', '-6.6926692,108.4970191', 'uploads/1756989778_Picsart_25-09-04_10-23-19-687.jpg', 'Field trip bersama petani binaan kios suci Mulya tani dan kelompok tani pak senang dilahan pa Agus kawal dan melihat performa jagung Lilac serta mengenalkan jagung manis madu, Reva dan menginfokan jagung baru h72\r\nAlhamdulillah tanam kembali 6 Lilac 4 madu', '2025-09-04 19:42:59', '2025-09-09 19:23:38', 5, 5),
(328, 5, 82, '2025-09-04', 'satisfactory', '-6.6913417,108.4993834', 'uploads/1756990271_IMG20250904165932_01.jpg', 'Tanaman jagung madu umur 70 dan 68. Untuk performa jagung madu umur 70 tumbuh optimal namun ada beberapa yang terkena kresek dan siwil masih muncul banyak. Untuk yang umur 68 optimal namun tanaman yang ternaung pohon nangka tanamannya tumbuh pendek', '2025-09-04 19:51:12', NULL, 5, NULL),
(329, 5, 180, '2025-09-02', 'satisfactory', '-6.6913417,108.4993834', 'uploads/1756991192_IMG20250901163316.jpg', 'Penanaman Lilac dilahan pak sihab dititik pertama,Alhamdulillah optimal walaupun waktu penaman terendam air hujan selama 2 hari', '2025-09-04 20:06:32', NULL, 5, NULL),
(330, 7, 173, '2025-09-08', 'satisfactory', NULL, 'uploads/1757298560_1000529150.jpg', NULL, '2025-09-08 09:29:21', NULL, 7, NULL),
(331, 7, 171, '2025-09-08', 'satisfactory', NULL, 'uploads/1757298595_1000529147.jpg', NULL, '2025-09-08 09:29:55', NULL, 7, NULL),
(332, 7, 130, '2025-09-08', 'satisfactory', NULL, 'uploads/1757298901_1000529161.jpg', NULL, '2025-09-08 09:35:01', NULL, 7, NULL),
(333, 7, 153, '2025-09-08', 'satisfactory', NULL, 'uploads/1757310401_1000529654.jpg', NULL, '2025-09-08 12:46:41', NULL, 7, NULL),
(334, 7, 154, '2025-09-09', 'satisfactory', NULL, 'uploads/1757408178_1000531041.jpg', NULL, '2025-09-09 15:56:18', NULL, 7, NULL),
(335, 7, 23, '2025-09-09', 'completed', NULL, 'uploads/1757408275_1000515765.jpg', NULL, '2025-09-09 15:57:55', '2025-09-09 15:58:31', 7, 7),
(336, 6, 19, '2025-09-09', 'completed', NULL, 'uploads/1757409203_IMG-20250812-WA0015.jpg', NULL, '2025-09-09 16:13:23', NULL, 6, NULL),
(337, 6, 18, '2025-09-09', 'completed', NULL, 'uploads/1757409398_IMG-20250812-WA0006.jpg', NULL, '2025-09-09 16:16:38', NULL, 6, NULL),
(338, 6, 132, '2025-09-09', 'completed', NULL, 'uploads/1757409528_IMG-20250812-WA0020.jpg', NULL, '2025-09-09 16:18:48', NULL, 6, NULL),
(339, 6, 42, '2025-09-09', 'completed', NULL, 'uploads/1757409636_IMG-20250812-WA0016.jpg', NULL, '2025-09-09 16:20:37', NULL, 6, NULL),
(340, 6, 127, '2025-09-09', 'completed', NULL, 'uploads/1757409711_IMG-20250812-WA0006.jpg', NULL, '2025-09-09 16:21:52', NULL, 6, NULL),
(341, 6, 72, '2025-09-09', 'completed', NULL, 'uploads/1757409795_IMG-20250812-WA0006.jpg', NULL, '2025-09-09 16:23:16', NULL, 6, NULL),
(342, 6, 116, '2025-09-09', 'completed', NULL, 'uploads/1757409877_IMG-20250812-WA0016.jpg', NULL, '2025-09-09 16:24:38', NULL, 6, NULL),
(343, 6, 183, '2025-09-06', 'satisfactory', NULL, 'uploads/1757410281_IMG_2418.png', NULL, '2025-09-09 16:31:21', NULL, 6, NULL),
(344, 5, 180, '2025-09-09', 'satisfactory', NULL, 'uploads/1757420354_IMG20250909140015.jpg', 'Tanaman tumbuh optimal dengan serempak namun posisi saat ini sedang kekurangan air sehingga beberapa tanaman layu serta mati', '2025-09-09 19:19:15', NULL, 5, NULL),
(345, 5, 82, '2025-09-07', 'satisfactory', NULL, 'uploads/1757420549_IMG-20250907-WA0022.jpg', 'Posisi sedang dipanen secara bertahap sesuai kebutuhan tengkulak langganan nya. Untuk buah bagus maksimal namun siwil masih keluar sehingga terlihat mengurangi  bobot jagung utama. Serta tanaman 20% terkenaserangan kresek daun', '2025-09-09 19:22:29', NULL, 5, NULL),
(346, 5, 119, '2025-09-07', 'satisfactory', NULL, 'uploads/1757420746_IMG20250906102039.jpg', 'Tanaman jagung reva tumbuh optimal namun angin terlalu kencang sehingga beberapa tanaman pada roboh', '2025-09-09 19:25:47', NULL, 5, NULL),
(347, 5, 60, '2025-09-09', 'completed', NULL, 'uploads/1757420927_IMG20250909104659.jpg', 'Posisi panen tidak terkawal', '2025-09-09 19:28:48', '2025-09-09 19:28:55', 5, 5),
(348, 5, 128, '2025-09-09', 'satisfactory', NULL, 'uploads/1757421039_IMG20250909104848.jpg', 'Tanaman tumbuh optimal. Namun jarak tanam setelah tanaman tumbuh terpantau terlalu rapat', '2025-09-09 19:30:39', NULL, 5, NULL),
(349, 5, 59, '2025-09-09', 'satisfactory', NULL, 'uploads/1757421188_IMG20250909110914.jpg', 'Terpantau tanaman mas Hadi banyak yang tidak tumbuh karena posisi kekeringan sehingga dilakukan penyulaman kembali', '2025-09-09 19:33:09', NULL, 5, NULL),
(350, 5, 126, '2025-09-09', 'satisfactory', NULL, 'uploads/1757421387_IMG20250909112913_01.jpg', 'Tanaman terendam air hujan pertumbuhan yang memuaskan hanya dibeberapa petak', '2025-09-09 19:36:27', NULL, 5, NULL),
(351, 5, 184, '2025-09-09', 'satisfactory', NULL, 'uploads/1757421663_Screenshot_2025-09-09-19-40-48-69_40deb401b9ffe8e1df2f1cc5ba480b12.jpg', 'Alhamdulillah tanaman tumbuh serempak dan kondisi pengairan aman dan sedang dilakukan pencegahan penanganan hama ulat menggunakan aplikasi obat emacel', '2025-09-09 19:41:03', NULL, 5, NULL),
(352, 5, 185, '2025-09-09', 'satisfactory', NULL, 'uploads/1757421830_IMG20250909104424.jpg', 'Posisi tanaman kekurangan air. Sudah dilakukan pengarahan untuk proses penyiraman kembali', '2025-09-09 19:43:51', NULL, 5, NULL),
(353, 5, 186, '2025-09-09', 'satisfactory', NULL, 'uploads/1757422032_IMG20250909130939.jpg', 'Pencarian air untuk pengairan karena sumur bor tidak keluar air', '2025-09-09 19:47:12', NULL, 5, NULL),
(354, 7, 70, '2025-09-09', 'completed', NULL, 'uploads/1757424697_1000531400.jpg', NULL, '2025-09-09 20:31:38', NULL, 7, NULL),
(355, 7, 78, '2025-09-10', 'completed', NULL, 'uploads/1757456140_1000531564.jpg', NULL, '2025-09-10 05:15:40', NULL, 7, NULL),
(356, 7, 187, '2025-09-10', 'satisfactory', NULL, 'uploads/1757456190_1000529291.jpg', NULL, '2025-09-10 05:16:30', NULL, 7, NULL),
(357, 17, 189, '2025-09-10', 'satisfactory', NULL, 'uploads/1757508971_corn-field-440338_1280.jpg', NULL, '2025-09-10 19:56:11', NULL, 17, NULL),
(358, 17, 189, '2025-09-10', 'failed', NULL, 'uploads/1757508995_WhatsApp Image 2025-08-19 at 15.06.11_5bfa193c.jpg', NULL, '2025-09-10 19:56:35', NULL, 17, NULL),
(359, 6, 122, '2025-09-11', 'satisfactory', NULL, 'uploads/1757564867_IMG-20250911-WA0016.jpg', NULL, '2025-09-11 11:27:47', NULL, 6, NULL),
(360, 8, 144, '2025-09-11', 'satisfactory', NULL, 'uploads/1757568071_PhotoGrid_Plus_1757567891759.jpg', NULL, '2025-09-11 12:21:12', NULL, 8, NULL),
(361, 8, 190, '2025-09-11', 'satisfactory', NULL, 'uploads/1757572579_PhotoGrid_Plus_1757572384072.jpg', NULL, '2025-09-11 13:36:20', NULL, 8, NULL),
(362, 8, 191, '2025-09-11', 'satisfactory', NULL, 'uploads/1757572789_PhotoGrid_Plus_1757572420714.jpg', NULL, '2025-09-11 13:39:49', NULL, 8, NULL),
(363, 7, 150, '2025-09-11', 'satisfactory', NULL, 'uploads/1757576607_1000533926.jpg', NULL, '2025-09-11 14:43:27', NULL, 7, NULL),
(364, 7, 149, '2025-09-11', 'satisfactory', NULL, 'uploads/1757576654_1000533923.jpg', NULL, '2025-09-11 14:44:14', NULL, 7, NULL),
(365, 6, 41, '2025-09-11', 'completed', NULL, 'uploads/1757590085_IMG_2609.jpeg', NULL, '2025-09-11 18:28:05', '2025-11-14 09:41:26', 6, 6),
(366, 6, 158, '2025-09-11', 'completed', NULL, 'uploads/1757590175_IMG_2602.jpeg', NULL, '2025-09-11 18:29:35', '2025-12-05 21:22:57', 6, 6),
(367, 6, 183, '2025-09-12', 'satisfactory', NULL, 'uploads/1757638488_IMG_2617.jpeg', NULL, '2025-09-12 07:54:49', NULL, 6, NULL),
(368, 6, 166, '2025-09-12', 'completed', NULL, 'uploads/1757646577_IMG_2627.jpeg', NULL, '2025-09-12 10:09:38', '2025-09-22 15:58:27', 6, 6),
(369, 8, 192, '2025-09-12', 'satisfactory', NULL, 'uploads/1757652510_PhotoGrid_Plus_1757652401372.jpg', NULL, '2025-09-12 11:48:30', NULL, 8, NULL),
(370, 8, 193, '2025-09-12', 'satisfactory', NULL, 'uploads/1757652567_PhotoGrid_Plus_1757652368908.jpg', NULL, '2025-09-12 11:49:28', NULL, 8, NULL),
(371, 6, 162, '2025-09-12', 'satisfactory', NULL, 'uploads/1757653171_IMG_2636.jpeg', NULL, '2025-09-12 11:59:31', NULL, 6, NULL),
(372, 8, 85, '2025-09-12', 'satisfactory', NULL, 'uploads/1757662760_PhotoGrid_Plus_1757662648724.jpg', NULL, '2025-09-12 14:39:20', NULL, 8, NULL),
(373, 6, 163, '2025-09-12', 'satisfactory', NULL, 'uploads/1757692126_IMG_2619.jpeg', NULL, '2025-09-12 22:48:47', NULL, 6, NULL),
(374, 6, 194, '2025-09-12', 'satisfactory', NULL, 'uploads/1757692435_2b2d9cf9-7e81-4c84-8ab3-71ba41809f4a.jpeg', NULL, '2025-09-12 22:53:55', NULL, 6, NULL),
(375, 6, 165, '2025-09-12', 'satisfactory', NULL, 'uploads/1757692511_IMG_2625.jpeg', NULL, '2025-09-12 22:55:11', NULL, 6, NULL),
(376, 6, 164, '2025-09-12', 'satisfactory', NULL, 'uploads/1757692747_IMG_2626.jpeg', NULL, '2025-09-12 22:59:08', NULL, 6, NULL),
(377, 6, 195, '2025-09-12', 'satisfactory', NULL, 'uploads/1757692984_IMG_2641.jpeg', NULL, '2025-09-12 23:03:04', NULL, 6, NULL),
(378, 6, 120, '2025-09-12', 'satisfactory', NULL, 'uploads/1757693041_IMG_2644.jpeg', NULL, '2025-09-12 23:04:01', NULL, 6, NULL),
(379, 8, 142, '2025-09-15', 'satisfactory', NULL, 'uploads/1757912184_PhotoGrid_Plus_1757911926599.jpg', NULL, '2025-09-15 11:56:24', NULL, 8, NULL),
(380, 8, 97, '2025-09-15', 'satisfactory', NULL, 'uploads/1757912257_PhotoGrid_Plus_1757909253909.jpg', NULL, '2025-09-15 11:57:38', NULL, 8, NULL),
(381, 8, 159, '2025-09-15', 'satisfactory', NULL, 'uploads/1757912335_PhotoGrid_Plus_1757909291117.jpg', NULL, '2025-09-15 11:58:55', NULL, 8, NULL),
(382, 8, 139, '2025-09-15', 'satisfactory', NULL, 'uploads/1757912389_PhotoGrid_Plus_1757909196113.jpg', NULL, '2025-09-15 11:59:49', NULL, 8, NULL),
(383, 7, 196, '2025-09-15', 'satisfactory', NULL, 'uploads/1757935828_1000539183.jpg', NULL, '2025-09-15 18:30:28', NULL, 7, NULL),
(384, 21, 198, '2025-09-15', 'satisfactory', NULL, 'uploads/1757948982_1000110960.jpg', NULL, '2025-09-15 22:09:42', NULL, 21, NULL),
(385, 21, 199, '2025-09-15', 'satisfactory', NULL, 'uploads/1757949439_1000110968.jpg', 'Terserang virus', '2025-09-15 22:17:19', NULL, 21, NULL),
(386, 8, 202, '2025-09-16', 'satisfactory', NULL, 'uploads/1757998523_PhotoGrid_Plus_1757996824425.jpg', NULL, '2025-09-16 11:55:23', NULL, 8, NULL),
(387, 8, 203, '2025-09-16', 'satisfactory', NULL, 'uploads/1758006239_PhotoGrid_Plus_1758004833612.jpg', NULL, '2025-09-16 14:03:59', NULL, 8, NULL),
(388, 8, 182, '2025-09-16', 'satisfactory', NULL, 'uploads/1758009495_20250916_145411.jpg', NULL, '2025-09-16 14:58:16', NULL, 8, NULL),
(389, 7, 171, '2025-09-17', 'satisfactory', NULL, 'uploads/1758074764_1000541061.jpg', NULL, '2025-09-17 09:06:04', NULL, 7, NULL),
(390, 5, 119, '2025-09-17', 'satisfactory', NULL, 'uploads/1758093262_IMG20250917140617.jpg', NULL, '2025-09-17 14:14:23', NULL, 5, NULL),
(391, 7, 150, '2025-09-18', 'satisfactory', NULL, 'uploads/1758150575_1000542316.jpg', NULL, '2025-09-18 06:09:36', NULL, 7, NULL),
(392, 7, 177, '2025-09-18', 'satisfactory', NULL, 'uploads/1758150642_1000542315.jpg', NULL, '2025-09-18 06:10:43', NULL, 7, NULL),
(393, 7, 178, '2025-09-18', 'satisfactory', NULL, 'uploads/1758150701_1000542317.jpg', NULL, '2025-09-18 06:11:41', NULL, 7, NULL),
(394, 7, 179, '2025-09-18', 'satisfactory', NULL, 'uploads/1758150820_1000542322.jpg', NULL, '2025-09-18 06:13:40', NULL, 7, NULL),
(395, 11, 207, '2025-09-01', 'completed', '-6.8304513,107.1683509', 'uploads/1758158145_Screenshot_20250918-081451_1.jpg', 'Ketahanan bulai cukup baik dan Ketahanan Ngeresek Juga lumayan masih baik, diketinggian menengah kenatas, dengan asumsi DB di beberapa titim kursng baik namun disini alhamdulillah baik dan memeuaskan dengan Umur (±) 45 Hst', '2025-09-18 08:15:45', '2025-12-19 06:14:46', 11, 11),
(396, 11, 156, '2025-08-21', 'completed', '-6.8304527,107.1683486', 'uploads/1758158645_IMG_20250904_135557_322.jpg', 'Ketahanan Virus cukup sangat bail dengan Umur (±) 35 Hst panenan Pertama', '2025-09-18 08:19:56', '2025-10-02 12:36:44', 11, 11),
(397, 7, 130, '2025-09-18', 'satisfactory', NULL, 'uploads/1758181120_1000543075.jpg', NULL, '2025-09-18 14:38:40', NULL, 7, NULL),
(398, 7, 206, '2025-09-18', 'satisfactory', NULL, 'uploads/1758181211_1000543077.jpg', NULL, '2025-09-18 14:40:11', NULL, 7, NULL),
(399, 7, 170, '2025-09-18', 'satisfactory', NULL, 'uploads/1758181280_1000543076.jpg', NULL, '2025-09-18 14:41:20', NULL, 7, NULL),
(400, 8, 193, '2025-09-19', 'completed', NULL, 'uploads/1758252618_PhotoGrid_Plus_1758252526200.jpg', NULL, '2025-09-19 10:30:18', '2026-01-21 15:21:54', 8, 8),
(401, 6, 165, '2025-09-19', 'satisfactory', NULL, 'uploads/1758289093_IMG_2939.jpeg', NULL, '2025-09-19 20:38:13', NULL, 6, NULL),
(402, 6, 163, '2025-09-19', 'satisfactory', NULL, 'uploads/1758289166_IMG_2937.jpeg', NULL, '2025-09-19 20:39:26', NULL, 6, NULL),
(403, 6, 194, '2025-09-19', 'satisfactory', NULL, 'uploads/1758289224_IMG_2938.jpeg', NULL, '2025-09-19 20:40:24', NULL, 6, NULL),
(404, 6, 208, '2025-09-19', 'satisfactory', NULL, 'uploads/1758289383_IMG_2912.jpeg', NULL, '2025-09-19 20:43:03', NULL, 6, NULL),
(405, 6, 209, '2025-09-19', 'satisfactory', NULL, 'uploads/1758289628_5b8bccd3-c71d-4413-b19d-6a8ac72d8a62.jpeg', NULL, '2025-09-19 20:47:08', NULL, 6, NULL),
(406, 6, 210, '2025-09-19', 'satisfactory', NULL, 'uploads/1758289761_IMG_2919.jpeg', NULL, '2025-09-19 20:49:22', NULL, 6, NULL),
(407, 6, 148, '2025-09-18', 'satisfactory', NULL, 'uploads/1758387125_cf5ef6df-9b0c-47ea-8fae-0f064c6ffc05.jpeg', NULL, '2025-09-20 23:52:05', NULL, 6, NULL),
(408, 8, 144, '2025-09-22', 'completed', NULL, 'uploads/1758512883_PhotoGrid_Plus_1758512746749.jpg', 'Panen', '2025-09-22 10:48:04', NULL, 8, NULL),
(409, 8, 191, '2025-09-22', 'satisfactory', NULL, 'uploads/1758527023_PhotoGrid_Plus_1758526718691.jpg', NULL, '2025-09-22 14:43:44', NULL, 8, NULL),
(410, 8, 190, '2025-09-22', 'satisfactory', NULL, 'uploads/1758527054_PhotoGrid_Plus_1758526680736.jpg', NULL, '2025-09-22 14:44:14', NULL, 8, NULL),
(411, 6, 183, '2025-09-22', 'satisfactory', NULL, 'uploads/1758530429_IMG_2967.jpeg', NULL, '2025-09-22 15:40:29', NULL, 6, NULL),
(412, 6, 162, '2025-09-22', 'satisfactory', NULL, 'uploads/1758530555_IMG_2975.jpeg', NULL, '2025-09-22 15:42:36', NULL, 6, NULL),
(413, 6, 163, '2025-09-22', 'satisfactory', NULL, 'uploads/1758530666_IMG_2968.jpeg', NULL, '2025-09-22 15:44:26', NULL, 6, NULL),
(414, 6, 194, '2025-09-22', 'satisfactory', NULL, 'uploads/1758531048_IMG_2969.jpeg', NULL, '2025-09-22 15:50:49', NULL, 6, NULL),
(415, 6, 195, '2025-09-22', 'completed', NULL, 'uploads/1758531192_IMG_2978.jpeg', NULL, '2025-09-22 15:53:12', NULL, 6, NULL),
(416, 6, 165, '2025-09-22', 'satisfactory', NULL, 'uploads/1758531308_IMG_2970.jpeg', NULL, '2025-09-22 15:55:09', NULL, 6, NULL),
(417, 6, 164, '2025-09-22', 'completed', NULL, 'uploads/1758531457_IMG_2972.jpeg', NULL, '2025-09-22 15:57:37', '2025-10-17 21:18:24', 6, 6),
(418, 6, 212, '2025-09-22', 'satisfactory', NULL, 'uploads/1758532262_fb4e7b69-2bcb-4ed8-bbcc-81e5fea4ba43.jpeg', NULL, '2025-09-22 16:11:03', NULL, 6, NULL),
(419, 6, 213, '2025-09-22', 'satisfactory', NULL, 'uploads/1758532546_4bde48da-95b9-44c1-a301-4c50ddc87720.jpeg', NULL, '2025-09-22 16:15:46', NULL, 6, NULL),
(420, 6, 120, '2025-09-22', 'satisfactory', NULL, 'uploads/1758532670_IMG_2986.jpeg', NULL, '2025-09-22 16:17:50', NULL, 6, NULL),
(421, 6, 71, '2025-09-22', 'satisfactory', NULL, 'uploads/1758532829_def0a39b-0aee-4222-8998-a652fdb7f161.jpeg', NULL, '2025-09-22 16:20:29', NULL, 6, NULL),
(422, 5, 58, '2025-09-17', 'satisfactory', NULL, 'uploads/1758633921_IMG-20250923-WA0183.jpg', 'Gulma terlalu lebat dan sedang dilakukan penyemprotan anti gulma', '2025-09-23 20:25:22', NULL, 5, NULL),
(423, 5, 214, '2025-09-17', 'satisfactory', NULL, 'uploads/1758634048_IMG-20250923-WA0182.jpg', 'Penanaman jagung madu 1-2 bungkus', '2025-09-23 20:27:28', NULL, 5, NULL),
(424, 5, 215, '2025-09-17', 'satisfactory', NULL, 'uploads/1758634193_IMG-20250923-WA0181.jpg', 'Penanaman jagung Lilac bungkus bareng dengan jagung madu', '2025-09-23 20:29:54', NULL, 5, NULL),
(425, 5, 57, '2025-09-18', 'satisfactory', NULL, 'uploads/1758634886_IMG20250918113255.jpg', 'Pertumbuhan Alhamdulillah bagus dan serempak', '2025-09-23 20:41:27', NULL, 5, NULL),
(426, 5, 185, '2025-09-19', 'satisfactory', NULL, 'uploads/1758635156_IMG20250918163456.jpg', '10% tanaman tidak tumbuh optimal indikasi ph terlalu asam', '2025-09-23 20:45:56', NULL, 5, NULL),
(427, 5, 59, '2025-09-19', 'satisfactory', NULL, 'uploads/1758635249_IMG20250915173749.jpg', NULL, '2025-09-23 20:47:30', NULL, 5, NULL),
(428, 5, 136, '2025-09-15', 'satisfactory', NULL, 'uploads/1758635770_IMG20250915160944.jpg', NULL, '2025-09-23 20:56:11', NULL, 5, NULL),
(429, 6, 219, '2025-09-24', 'satisfactory', NULL, 'uploads/1758712464_IMG_3081.jpeg', NULL, '2025-09-24 18:14:25', NULL, 6, NULL),
(430, 6, 175, '2025-09-24', 'satisfactory', NULL, 'uploads/1758712595_36626be2-1597-4546-b7b3-9bf31a607f62.jpeg', NULL, '2025-09-24 18:16:35', NULL, 6, NULL),
(431, 6, 134, '2025-09-24', 'completed', NULL, 'uploads/1758712740_IMG_3077.jpeg', NULL, '2025-09-24 18:19:01', '2025-10-30 21:30:56', 6, 6),
(432, 7, 205, '2025-09-25', 'satisfactory', NULL, 'uploads/1758769360_1000551710.jpg', NULL, '2025-09-25 10:02:40', NULL, 7, NULL),
(433, 7, 196, '2025-09-25', 'satisfactory', NULL, 'uploads/1758773581_1000551857.jpg', NULL, '2025-09-25 11:13:01', NULL, 7, NULL),
(434, 7, 220, '2025-09-26', 'satisfactory', NULL, 'uploads/1758844309_1000552831.jpg', NULL, '2025-09-26 06:51:49', NULL, 7, NULL),
(435, 5, 57, '2025-09-24', 'satisfactory', NULL, 'uploads/1758844358_IMG20250924110946.jpg', NULL, '2025-09-26 06:52:38', NULL, 5, NULL),
(436, 7, 47, '2025-09-26', 'satisfactory', NULL, 'uploads/1758844361_1000552832.jpg', 'Petikanke 7', '2025-09-26 06:52:41', '2025-09-26 06:53:54', 7, 7),
(437, 5, 31, '2025-09-24', 'satisfactory', NULL, 'uploads/1758844648_IMG20250924164921.jpg', 'Umur tanaman 10 hst penanaman Lilac bertahap untuk dilahan ini penanaman 5 pcs dan sisanya disebar', '2025-09-26 06:57:29', NULL, 5, NULL),
(438, 8, 223, '2025-09-26', 'satisfactory', NULL, 'uploads/1758856544_IMG-20250926-WA0004.jpg', NULL, '2025-09-26 10:15:44', NULL, 8, NULL),
(439, 8, 224, '2025-09-26', 'satisfactory', NULL, 'uploads/1758860785_20250926_112141.jpg', NULL, '2025-09-26 11:26:25', NULL, 8, NULL),
(440, 8, 85, '2025-09-26', 'satisfactory', NULL, 'uploads/1758861073_PhotoGrid_Plus_1758861028659.jpg', NULL, '2025-09-26 11:31:13', NULL, 8, NULL),
(441, 8, 225, '2025-09-26', 'satisfactory', NULL, 'uploads/1758873166_20250926_144751.jpg', NULL, '2025-09-26 14:52:47', NULL, 8, NULL),
(442, 8, 226, '2025-09-26', 'satisfactory', NULL, 'uploads/1758873369_PhotoGrid_Plus_1758873335093.jpg', NULL, '2025-09-26 14:56:09', NULL, 8, NULL),
(443, 8, 159, '2025-09-26', 'satisfactory', NULL, 'uploads/1758877644_PhotoGrid_Plus_1758875746782.jpg', NULL, '2025-09-26 16:07:24', NULL, 8, NULL),
(444, 8, 97, '2025-09-26', 'satisfactory', NULL, 'uploads/1758877691_PhotoGrid_Plus_1758875609424.jpg', NULL, '2025-09-26 16:08:12', NULL, 8, NULL),
(445, 8, 139, '2025-09-26', 'satisfactory', NULL, 'uploads/1758877735_PhotoGrid_Plus_1758875689185.jpg', NULL, '2025-09-26 16:08:56', NULL, 8, NULL),
(446, 7, 84, '2025-09-27', 'satisfactory', NULL, 'uploads/1758955955_1000554617.jpg', NULL, '2025-09-27 13:52:35', NULL, 7, NULL),
(447, 16, 228, '2025-09-29', 'satisfactory', NULL, 'uploads/1759155888_IMG_0399.jpeg', 'Untuk pertumbuhan dengan kompotitor ( semi ) keliat seimbang sekalipun waktu tanam beda satu hati di banding lavanta, petani serta bandarnya nunggu warna buah dan kualitas buah', '2025-09-29 21:24:50', NULL, 16, NULL),
(448, 5, 64, '2025-09-29', 'satisfactory', NULL, 'uploads/1759161138_IMG20250929151852.jpg', 'Kontrol dan atur jadwal panen serta ajak bandar pak Roni untuk dipasarkan dipasar Cibitung', '2025-09-29 22:52:19', NULL, 5, NULL),
(449, 5, 125, '2025-09-29', 'satisfactory', NULL, 'uploads/1759161209_IMG20250929151748.jpg', 'Cek performa buah dari benih Reva Dan Anara dilahan pak kurman', '2025-09-29 22:53:29', NULL, 5, NULL),
(450, 5, 204, '2025-09-24', 'satisfactory', NULL, 'uploads/1759161460_IMG20250924165112.jpg', 'Cek pertumbuhan Jagung Lilac dilahan binann pak opik', '2025-09-29 22:55:40', '2025-09-29 22:57:41', 5, 5),
(451, 5, 136, '2025-09-26', 'satisfactory', NULL, 'uploads/1759161642_IMG20250926150615.jpg', 'Jagung sudah mulai proses pemanenan diwilayah sawah gede dengan sistim tumpang sari dengan kacang dan persiapan dipanen bertahap', '2025-09-29 23:00:42', NULL, 5, NULL),
(452, 5, 59, '2025-09-29', 'satisfactory', NULL, 'uploads/1759161767_IMG20250926103012.jpg', NULL, '2025-09-29 23:02:48', NULL, 5, NULL),
(453, 5, 185, '2025-09-26', 'satisfactory', NULL, 'uploads/1759161918_IMG20250926100731.jpg', 'Tanaman aman dari hama namun terdapat beberapa tanaman yang kerdil dikarenakan ph tanah terlalu tinggi', '2025-09-29 23:05:18', NULL, 5, NULL),
(454, 5, 215, '2025-09-26', 'satisfactory', NULL, 'uploads/1759162106_Screenshot_2025-09-29-23-17-10-19_40deb401b9ffe8e1df2f1cc5ba480b12.jpg', 'Tanaman tumbuh serempak Alhamdulillah performa maksimal', '2025-09-29 23:08:26', NULL, 5, NULL),
(455, 5, 214, '2025-09-29', 'satisfactory', NULL, 'uploads/1759162187_IMG20250926151640.jpg', 'Terdapat serangan lalat bibit', '2025-09-29 23:09:48', NULL, 5, NULL),
(456, 5, 58, '2025-09-29', 'satisfactory', NULL, 'uploads/1759162286_IMG20250926151536.jpg', 'Gulma terlalu banyak sehingga mengganggu pertumbuhan tanaman inti', '2025-09-29 23:11:26', NULL, 5, NULL),
(457, 5, 119, '2025-09-26', 'satisfactory', NULL, 'uploads/1759162356_IMG20250926152350.jpg', 'Proses pemetikan putren', '2025-09-29 23:12:36', NULL, 5, NULL),
(458, 5, 180, '2025-09-29', 'satisfactory', NULL, 'uploads/1759162460_IMG20250929084803.jpg', 'Ada beberapa tanaman Pertumbuhanya tidak merata karena daya tumbuh tidak sama', '2025-09-29 23:14:20', NULL, 5, NULL),
(459, 5, 145, '2025-09-29', 'satisfactory', NULL, 'uploads/1759162518_IMG20250929110954.jpg', 'Tanaman tidak optimal', '2025-09-29 23:15:18', NULL, 5, NULL),
(460, 5, 113, '2025-09-29', 'satisfactory', NULL, 'uploads/1759162562_IMG20250929151958.jpg', NULL, '2025-09-29 23:16:03', NULL, 5, NULL),
(461, 5, 128, '2025-09-29', 'satisfactory', NULL, 'uploads/1759163550_IMG-20250929-WA0111.jpg', 'Cek sampling hasil buah Lilac dan atur jadwal panen', '2025-09-29 23:32:30', NULL, 5, NULL),
(462, 5, 186, '2025-09-29', 'satisfactory', NULL, 'uploads/1759163671_IMG20250926115450_01.jpg', 'Cek performa perkembangan pertumbuhan tanaman Jagung Lilac dilahan mang likun ke 2', '2025-09-29 23:34:31', NULL, 5, NULL),
(463, 5, 126, '2025-09-29', 'satisfactory', NULL, 'uploads/1759163827_IMG20250926115011.jpg', 'Tanaman sudah berbuah namun tidak terlalu maksimal karena sempat terendam banjir', '2025-09-29 23:37:07', NULL, 5, NULL),
(464, 6, 162, '2025-09-30', 'completed', NULL, 'uploads/1759223276_IMG_0062.jpeg', NULL, '2025-09-30 16:07:56', '2025-10-10 10:30:53', 6, 6),
(465, 6, 183, '2025-09-30', 'satisfactory', NULL, 'uploads/1759223504_2286ed20-c825-4de3-8b8d-ee0847553937.jpeg', NULL, '2025-09-30 16:11:44', NULL, 6, NULL),
(466, 6, 230, '2025-09-30', 'satisfactory', NULL, 'uploads/1759223637_IMG_0063.jpeg', NULL, '2025-09-30 16:13:58', NULL, 6, NULL),
(467, 6, 163, '2025-09-30', 'satisfactory', NULL, 'uploads/1759223748_1af8480d-5ec3-4e92-aaac-16d79539b8b0.jpeg', NULL, '2025-09-30 16:15:48', NULL, 6, NULL),
(468, 6, 194, '2025-09-30', 'satisfactory', NULL, 'uploads/1759223922_IMG_0067.jpeg', NULL, '2025-09-30 16:18:43', NULL, 6, NULL),
(469, 6, 165, '2025-09-30', 'satisfactory', NULL, 'uploads/1759224010_IMG_0069.jpeg', NULL, '2025-09-30 16:20:10', NULL, 6, NULL),
(470, 6, 120, '2025-09-30', 'completed', NULL, 'uploads/1759224155_IMG_0076.jpeg', NULL, '2025-09-30 16:22:36', '2025-10-10 10:29:23', 6, 6),
(471, 6, 213, '2025-09-30', 'satisfactory', NULL, 'uploads/1759224282_255191da-3f6d-4a08-b198-11f8d696fc30.jpeg', NULL, '2025-09-30 16:24:43', NULL, 6, NULL),
(472, 6, 168, '2025-10-01', 'satisfactory', NULL, 'uploads/1759324599_IMG_20251001_201610_814.jpg', NULL, '2025-10-01 20:16:39', NULL, 6, NULL),
(473, 6, 71, '2025-10-01', 'completed', NULL, 'uploads/1759324701_IMG-20251001-WA0004.jpg', NULL, '2025-10-01 20:18:21', '2025-10-30 21:33:44', 6, 6),
(474, 7, 178, '2025-10-01', 'satisfactory', NULL, 'uploads/1759325541_1000560029.jpg', NULL, '2025-10-01 20:32:21', NULL, 7, NULL),
(475, 7, 150, '2025-10-01', 'satisfactory', NULL, 'uploads/1759325578_1000560030.jpg', NULL, '2025-10-01 20:32:58', NULL, 7, NULL),
(476, 7, 171, '2025-10-01', 'satisfactory', NULL, 'uploads/1759326827_1000560034.jpg', NULL, '2025-10-01 20:53:47', NULL, 7, NULL),
(477, 15, 231, '2025-10-02', 'satisfactory', NULL, 'uploads/1759394546_IMG_20251002_094648_1.jpg', 'Umur 55 hst', '2025-10-02 15:42:26', NULL, 15, NULL),
(478, 7, 232, '2025-10-03', 'satisfactory', NULL, 'uploads/1759450835_1000560033.jpg', NULL, '2025-10-03 07:20:36', NULL, 7, NULL),
(479, 8, 203, '2025-10-03', 'satisfactory', NULL, 'uploads/1759470941_PhotoGrid_Plus_1759463459291.jpg', NULL, '2025-10-03 12:55:41', NULL, 8, NULL),
(480, 8, 139, '2025-10-03', 'completed', NULL, 'uploads/1759471104_PhotoGrid_Plus_1759471000673.jpg', NULL, '2025-10-03 12:58:24', '2026-01-21 15:21:26', 8, 8),
(481, 8, 97, '2025-10-03', 'satisfactory', NULL, 'uploads/1759471218_PhotoGrid_Plus_1759471029635.jpg', NULL, '2025-10-03 13:00:18', NULL, 8, NULL),
(482, 6, 233, '2025-10-03', 'satisfactory', NULL, 'uploads/1759482613_IMG_0149.jpeg', NULL, '2025-10-03 16:10:14', NULL, 6, NULL),
(483, 6, 234, '2025-10-03', 'completed', NULL, 'uploads/1759482716_IMG_0150.jpeg', 'Tercampur exotic', '2025-10-03 16:11:57', '2025-10-30 21:29:42', 6, 6),
(484, 6, 235, '2025-10-03', 'completed', NULL, 'uploads/1759482835_IMG_0155.jpeg', NULL, '2025-10-03 16:13:55', '2025-12-05 21:23:57', 6, 6),
(485, 6, 236, '2025-10-03', 'satisfactory', NULL, 'uploads/1759482952_IMG_0162.jpeg', NULL, '2025-10-03 16:15:53', NULL, 6, NULL),
(486, 7, 206, '2025-10-05', 'satisfactory', NULL, 'uploads/1759635076_1000564261.jpg', NULL, '2025-10-05 10:31:16', NULL, 7, NULL),
(487, 7, 177, '2025-10-05', 'satisfactory', NULL, 'uploads/1759635125_1000560036.jpg', NULL, '2025-10-05 10:32:05', NULL, 7, NULL),
(488, 7, 153, '2025-10-05', 'unsatisfactory', NULL, 'uploads/1759635353_1000564271.jpg', 'Virus gemini', '2025-10-05 10:35:53', NULL, 7, NULL),
(489, 7, 220, '2025-10-05', 'satisfactory', NULL, 'uploads/1759635404_1000564268.jpg', NULL, '2025-10-05 10:36:45', NULL, 7, NULL),
(490, 7, 140, '2025-10-05', 'completed', NULL, 'uploads/1759635591_1000534303.jpg', NULL, '2025-10-05 10:39:52', NULL, 7, NULL),
(491, 7, 237, '2025-10-05', 'satisfactory', NULL, 'uploads/1759635888_1000551558.jpg', NULL, '2025-10-05 10:44:48', NULL, 7, NULL),
(492, 7, 67, '2025-10-05', 'completed', NULL, 'uploads/1759635942_1000561844.jpg', NULL, '2025-10-05 10:45:43', NULL, 7, NULL),
(493, 7, 170, '2025-10-05', 'satisfactory', NULL, 'uploads/1759636064_1000564284.jpg', NULL, '2025-10-05 10:47:44', NULL, 7, NULL),
(494, 7, 130, '2025-10-05', 'satisfactory', NULL, 'uploads/1759636093_1000564283.jpg', NULL, '2025-10-05 10:48:13', NULL, 7, NULL),
(495, 7, 238, '2025-10-07', 'satisfactory', NULL, 'uploads/1759804722_1000566686.jpg', NULL, '2025-10-07 09:38:42', NULL, 7, NULL),
(496, 6, 122, '2025-10-06', 'completed', NULL, 'uploads/1759804758_6eb4a222-d4c8-44f3-9c2a-35db9c08006f.jpeg', NULL, '2025-10-07 09:39:18', '2025-11-14 09:39:46', 6, 6),
(497, 6, 239, '2025-10-07', 'completed', NULL, 'uploads/1759805520_62da1959-c442-4701-b80a-f42d33968714.jpeg', NULL, '2025-10-07 09:52:00', '2025-12-25 20:09:00', 6, 6),
(498, 6, 240, '2025-10-07', 'completed', NULL, 'uploads/1759805638_IMG_0216.jpeg', NULL, '2025-10-07 09:53:59', '2025-12-05 21:24:46', 6, 6),
(499, 6, 241, '2025-10-09', 'satisfactory', NULL, 'uploads/1759973251_IMG_0246.jpeg', NULL, '2025-10-09 08:27:32', NULL, 6, NULL),
(500, 7, 220, '2025-10-10', 'satisfactory', NULL, 'uploads/1760070649_1000571217.jpg', NULL, '2025-10-10 11:30:49', NULL, 7, NULL),
(501, 7, 124, '2025-10-10', 'failed', NULL, 'uploads/1760071436_1000571238.jpg', 'Kesemprotobat rumput', '2025-10-10 11:43:56', NULL, 7, NULL),
(502, 7, 242, '2025-10-11', 'satisfactory', NULL, 'uploads/1760156828_1000572877.jpg', NULL, '2025-10-11 11:27:08', NULL, 7, NULL),
(503, 6, 211, '2025-10-14', 'satisfactory', NULL, 'uploads/1760429206_e0f83b60-c12f-4c59-ba9b-cd25815ac5c9.jpeg', NULL, '2025-10-14 15:06:47', NULL, 6, NULL),
(504, 6, 243, '2025-10-14', 'satisfactory', NULL, 'uploads/1760429340_IMG_0331.jpeg', NULL, '2025-10-14 15:09:00', NULL, 6, NULL),
(505, 6, 213, '2025-10-14', 'satisfactory', NULL, 'uploads/1760429496_e64ce4bc-88e3-4a69-8a22-07484a9c0b47.jpeg', NULL, '2025-10-14 15:11:36', NULL, 6, NULL),
(506, 6, 236, '2025-10-14', 'satisfactory', NULL, 'uploads/1760429648_6f558043-f2a0-417f-b52f-bf434a810f3c.jpeg', NULL, '2025-10-14 15:14:09', NULL, 6, NULL),
(507, 6, 244, '2025-10-14', 'satisfactory', NULL, 'uploads/1760429784_IMG_0338.jpeg', NULL, '2025-10-14 15:16:24', NULL, 6, NULL),
(508, 6, 200, '2025-10-15', 'completed', NULL, 'uploads/1760504015_IMG_0367.jpeg', NULL, '2025-10-15 11:53:36', '2025-11-14 09:38:54', 6, 6),
(509, 6, 175, '2025-10-15', 'satisfactory', NULL, 'uploads/1760534317_IMG_0377.jpeg', NULL, '2025-10-15 20:18:38', NULL, 6, NULL),
(510, 6, 219, '2025-10-15', 'completed', NULL, 'uploads/1760534467_e6319d5b-c2f7-4222-a804-e0507af7226a.jpeg', NULL, '2025-10-15 20:21:08', '2025-11-14 09:38:10', 6, 6),
(511, 6, 212, '2025-10-15', 'satisfactory', NULL, 'uploads/1760534562_6c576735-3841-4223-8507-ae09565a686f.jpeg', NULL, '2025-10-15 20:22:43', NULL, 6, NULL),
(512, 7, 130, '2025-10-15', 'completed', NULL, 'uploads/1760535473_1000578213.jpg', NULL, '2025-10-15 20:37:53', NULL, 7, NULL),
(513, 7, 170, '2025-10-15', 'completed', NULL, 'uploads/1760535513_1000578213.jpg', NULL, '2025-10-15 20:38:33', NULL, 7, NULL),
(514, 7, 173, '2025-10-15', 'completed', NULL, 'uploads/1760535544_1000578213.jpg', NULL, '2025-10-15 20:39:04', NULL, 7, NULL),
(515, 7, 206, '2025-10-15', 'satisfactory', NULL, 'uploads/1760535605_1000578211.jpg', NULL, '2025-10-15 20:40:05', NULL, 7, NULL),
(516, 7, 197, '2025-10-15', 'satisfactory', NULL, 'uploads/1760535692_1000578212.jpg', NULL, '2025-10-15 20:41:33', NULL, 7, NULL),
(517, 7, 245, '2025-10-15', 'satisfactory', NULL, 'uploads/1760535887_1000572877.jpg', NULL, '2025-10-15 20:44:47', NULL, 7, NULL),
(518, 7, 248, '2025-10-15', 'satisfactory', NULL, 'uploads/1760536368_1000578229.jpg', NULL, '2025-10-15 20:52:49', NULL, 7, NULL),
(519, 5, 126, '2025-10-13', 'satisfactory', NULL, 'uploads/1760620602_IMG-20251013-WA0007.jpg', 'Pemanenan jagung Lilac dilahan pak haji Bun. Kondisi terahir terendam air hujan 3x dan panenan kurang optimal hanya selamat 8 kwintal dan nyoba kembali tanam', '2025-10-16 20:16:42', NULL, 5, NULL),
(520, 5, 186, '2025-10-14', 'satisfactory', NULL, 'uploads/1760620774_IMG20251014105508.jpg', 'Pertumbuhan jagung lilac tumbuh dengan aman namunjagung madu tidak serempak ada yang sudah tinggi dan ada yang masih pendek', '2025-10-16 20:19:34', NULL, 5, NULL),
(521, 5, 128, '2025-10-01', 'satisfactory', NULL, 'uploads/1760621003_IMG20250930084024.jpg', 'Proses pemanenan sekaligus pelaksanaan studi banding', '2025-10-16 20:23:24', NULL, 5, NULL),
(522, 5, 113, '2025-10-16', 'satisfactory', NULL, 'uploads/1760621156_443d217f1dba4202b58004b4ce0e0fad.jpg', 'Dipanen dan digunakan acara croptour tim jabar', '2025-10-16 20:25:56', NULL, 5, NULL),
(523, 5, 180, '2025-10-14', 'satisfactory', NULL, 'uploads/1760621357_IMG20251014105706.jpg', 'Pertumbuhan optimal namun yang 8 bungkus terkendala pengairan', '2025-10-16 20:29:17', NULL, 5, NULL),
(524, 5, 119, '2025-10-04', 'satisfactory', NULL, 'uploads/1760621469_IMG20251004123510.jpg', 'Pertumbuhan aman dan buah maksimal', '2025-10-16 20:31:09', NULL, 5, NULL),
(525, 5, 58, '2025-10-04', 'satisfactory', NULL, 'uploads/1760621560_IMG20251004123305.jpg', 'Tanaman pertumbuhannya tidak serempak dan kebanjiran serta kekeringan', '2025-10-16 20:32:40', NULL, 5, NULL),
(526, 5, 214, '2025-10-04', 'satisfactory', NULL, 'uploads/1760621677_Screenshot_2025-10-16-20-34-06-09_40deb401b9ffe8e1df2f1cc5ba480b12.jpg', 'Tumbuh dengan optimal', '2025-10-16 20:34:37', NULL, 5, NULL),
(527, 5, 215, '2025-10-04', 'satisfactory', NULL, 'uploads/1760621783_Screenshot_2025-10-16-20-35-56-30_40deb401b9ffe8e1df2f1cc5ba480b12.jpg', 'Tumbuh dengan normal dan serempak belum ada gejala dan serangan hpt', '2025-10-16 20:36:23', NULL, 5, NULL),
(528, 5, 185, '2025-10-16', 'satisfactory', NULL, 'uploads/1760621860_IMG20251014093846.jpg', 'Tumbuh optimal dan serempak', '2025-10-16 20:37:41', NULL, 5, NULL),
(529, 5, 59, '2025-10-07', 'satisfactory', NULL, 'uploads/1760622004_IMG20251003110815.jpg', NULL, '2025-10-16 20:40:05', NULL, 5, NULL),
(530, 5, 125, '2025-10-10', 'satisfactory', NULL, 'uploads/1760622135_IMG20251010135557.jpg', 'Pemanenan dilakukan dihari senin', '2025-10-16 20:42:15', NULL, 5, NULL),
(531, 5, 184, '2025-10-14', 'satisfactory', NULL, 'uploads/1760622354_IMG20251014105722.jpg', 'Tanaman tumbuh optimal dan terjadi serangan busuk batang disetiap pinggir bedengan namun tidak terlalu banyak', '2025-10-16 20:45:54', NULL, 5, NULL),
(532, 5, 143, '2025-10-14', 'satisfactory', NULL, 'uploads/1760622466_IMG20251015095257.jpg', 'Cuaca saat ini sangat terik dan tanaman pada layu namun sudah diantisipasi untuk dilakukan penyiraman', '2025-10-16 20:47:46', NULL, 5, NULL),
(533, 5, 221, '2025-10-16', 'satisfactory', NULL, 'uploads/1760622558_IMG20251013143655.jpg', 'Tanaman tumbuh dengan serempak', '2025-10-16 20:49:18', NULL, 5, NULL),
(534, 5, 222, '2025-11-28', 'satisfactory', NULL, 'uploads/1764300349_IMG20251125123121.jpg', NULL, '2025-10-16 20:52:02', '2025-11-28 10:25:49', 5, 5),
(535, 5, 217, '2025-10-10', 'satisfactory', NULL, 'uploads/1760622891_IMG20251010092225.jpg', 'Pelaksanaan penanaman jagung madu', '2025-10-16 20:54:52', NULL, 5, NULL),
(536, 5, 249, '2025-10-14', 'satisfactory', NULL, 'uploads/1760623058_IMG20251014163104.jpg', NULL, '2025-10-16 20:57:38', NULL, 5, NULL),
(537, 5, 250, '2025-10-14', 'satisfactory', NULL, 'uploads/1760623168_IMG20251014155231.jpg', 'Proses penanaman jagung madu', '2025-10-16 20:59:28', NULL, 5, NULL),
(538, 5, 251, '2025-10-14', 'satisfactory', NULL, 'uploads/1760623311_IMG20251014095839.jpg', NULL, '2025-10-16 21:01:51', NULL, 5, NULL),
(539, 5, 252, '2025-10-13', 'satisfactory', NULL, 'uploads/1760623763_IMG20251013134735.jpg', 'Pertumbuhan serempak dan seragam serta putren hampir rata rata setiap pohon keluar 2-3 tongkol', '2025-10-16 21:09:23', NULL, 5, NULL),
(540, 8, 225, '2025-10-17', 'satisfactory', NULL, 'uploads/1760671812_PhotoGrid_Plus_1760671686708.jpg', NULL, '2025-10-17 10:30:13', NULL, 8, NULL),
(541, 6, 254, '2025-10-17', 'satisfactory', NULL, 'uploads/1760710237_IMG_0398.jpeg', NULL, '2025-10-17 21:10:38', NULL, 6, NULL),
(542, 6, 165, '2025-10-17', 'completed', NULL, 'uploads/1760710297_IMG_0399.jpeg', NULL, '2025-10-17 21:11:38', '2025-10-30 21:31:39', 6, 6),
(543, 6, 163, '2025-10-17', 'completed', NULL, 'uploads/1760710494_IMG_0400.jpeg', NULL, '2025-10-17 21:14:55', '2025-10-24 07:53:03', 6, 6),
(544, 6, 194, '2025-10-17', 'satisfactory', NULL, 'uploads/1760710586_IMG_0401.jpeg', NULL, '2025-10-17 21:16:27', NULL, 6, NULL),
(545, 8, 255, '2025-10-21', 'satisfactory', NULL, 'uploads/1761034730_PhotoGrid_Plus_1761034620532.jpg', NULL, '2025-10-21 15:18:50', NULL, 8, NULL),
(546, 8, 256, '2025-10-21', 'satisfactory', NULL, 'uploads/1761036498_PhotoGrid_Plus_1761036268914.jpg', NULL, '2025-10-21 15:48:18', NULL, 8, NULL),
(547, 8, 257, '2025-10-22', 'satisfactory', NULL, 'uploads/1761106103_PhotoGrid_Plus_1761105760693.jpg', NULL, '2025-10-22 11:08:23', NULL, 8, NULL),
(548, 8, 258, '2025-10-22', 'satisfactory', NULL, 'uploads/1761107673_PhotoGrid_Plus_1761106665681.jpg', NULL, '2025-10-22 11:34:33', NULL, 8, NULL),
(549, 8, 259, '2025-10-22', 'satisfactory', NULL, 'uploads/1761127152_PhotoGrid_Plus_1761126642118.jpg', NULL, '2025-10-22 16:59:12', NULL, 8, NULL),
(550, 8, 260, '2025-10-22', 'satisfactory', NULL, 'uploads/1761127294_20251022_165322.jpg', NULL, '2025-10-22 17:01:35', NULL, 8, NULL),
(551, 6, 212, '2025-10-23', 'completed', NULL, 'uploads/1761267282_IMG_0495.jpeg', NULL, '2025-10-24 07:54:42', '2026-01-13 18:08:27', 6, 6),
(552, 6, 175, '2025-10-23', 'completed', NULL, 'uploads/1761267373_IMG_0494.jpeg', NULL, '2025-10-24 07:56:14', '2025-11-14 09:37:05', 6, 6),
(553, 6, 183, '2025-10-23', 'satisfactory', NULL, 'uploads/1761267468_IMG_0488.jpeg', NULL, '2025-10-24 07:57:49', NULL, 6, NULL),
(554, 6, 233, '2025-10-23', 'satisfactory', NULL, 'uploads/1761267568_IMG_0479.jpeg', NULL, '2025-10-24 07:59:28', NULL, 6, NULL),
(555, 5, 252, '2025-10-24', 'satisfactory', NULL, 'uploads/1761270477_IMG20251023114828.jpg', 'Tanaman sudah tua tinggal menunggu hari untuk dilakukan pemanenan', '2025-10-24 08:47:58', NULL, 5, NULL),
(556, 5, 59, '2025-10-24', 'satisfactory', NULL, 'uploads/1761270709_IMG20251020171942.jpg', 'Pengecekan tanaman Lilac bersama bandar mas dion', '2025-10-24 08:50:06', '2025-10-24 08:51:49', 5, 5),
(557, 5, 184, '2025-10-24', 'satisfactory', NULL, 'uploads/1761270786_IMG20251020173758.jpg', 'Pengecekan tanaman Lilac bersama bandar mas dion', '2025-10-24 08:53:07', NULL, 5, NULL),
(558, 5, 180, '2025-10-24', 'satisfactory', NULL, 'uploads/1761270847_IMG20251020171304.jpg', 'Pengecekan tanaman Lilac bersama bandar mas dion', '2025-10-24 08:54:08', NULL, 5, NULL),
(559, 5, 204, '2025-10-20', 'satisfactory', NULL, 'uploads/1761270955_IMG20251017105520.jpg', 'Mengecek pertumbuhan tanaman Lilac dilahan binaan pak haji opik', '2025-10-24 08:55:56', NULL, 5, NULL),
(560, 5, 253, '2025-10-21', 'satisfactory', NULL, 'uploads/1761271099_IMG20251020174033_01.jpg', 'Cek pertumbuhan tanaman Lilac dilahan mang tawi', '2025-10-24 08:58:19', NULL, 5, NULL),
(561, 5, 216, '2025-10-17', 'satisfactory', NULL, 'uploads/1761271229_IMG20251017104058.jpg', 'Alhamdulillah pertumbuhan baik dan dilakukan penyemprotan obat ulat untuk ketahanan hama', '2025-10-24 09:00:30', NULL, 5, NULL),
(562, 5, 185, '2025-10-24', 'satisfactory', NULL, 'uploads/1761275501_IMG20251024094822.jpg', 'Cek pertumbuhan jagung Lilac dilahan mas gandi dan sedang dilakukan penyemprotan gandasil buah', '2025-10-24 10:11:41', NULL, 5, NULL),
(563, 5, 253, '2025-10-24', 'satisfactory', NULL, 'uploads/1761275556_IMG20251024095157_01.jpg', 'Cek pertumbuhan Tanaman Lilac Alhamdulillah pertumbuhan bagus', '2025-10-24 10:12:36', NULL, 5, NULL),
(564, 5, 263, '2025-10-24', 'satisfactory', NULL, 'uploads/1761275747_IMG20251024095426_01.jpg', 'Pertumbuhan jagung madu terlihat serempak dan maksimal', '2025-10-24 10:15:47', NULL, 5, NULL),
(565, 5, 214, '2025-10-24', 'satisfactory', NULL, 'uploads/1761287753_IMG20251024124458.jpg', 'Pertumbuhan alhamdulilla serempak', '2025-10-24 13:35:54', NULL, 5, NULL),
(566, 5, 215, '2025-10-24', 'satisfactory', NULL, 'uploads/1761287844_IMG20251024124626.jpg', 'Alhamdulillah serempak dan memuaskan', '2025-10-24 13:37:24', NULL, 5, NULL),
(567, 5, 58, '2025-10-24', 'satisfactory', NULL, 'uploads/1761287939_IMG20251024124359.jpg', 'Tinggi tanaman tidak normal tapi buah dipupuk dan diseprot buah sehingga masih aman', '2025-10-24 13:39:00', NULL, 5, NULL),
(568, 8, 225, '2025-10-27', 'satisfactory', NULL, 'uploads/1761548210_PhotoGrid_Plus_1761548052277.jpg', NULL, '2025-10-27 13:56:50', NULL, 8, NULL),
(569, 8, 142, '2025-10-27', 'satisfactory', NULL, 'uploads/1761548282_PhotoGrid_Plus_1761547990562.jpg', NULL, '2025-10-27 13:58:02', NULL, 8, NULL),
(570, 8, 226, '2025-10-27', 'satisfactory', NULL, 'uploads/1761548326_PhotoGrid_Plus_1761548153505.jpg', NULL, '2025-10-27 13:58:47', NULL, 8, NULL),
(571, 7, 271, '2025-10-28', 'satisfactory', NULL, 'uploads/1761622044_1000594008.jpg', NULL, '2025-10-28 10:27:24', NULL, 7, NULL),
(572, 8, 259, '2025-10-30', 'satisfactory', NULL, 'uploads/1761804387_PhotoGrid_Plus_1761804325891.jpg', NULL, '2025-10-30 13:06:27', NULL, 8, NULL),
(573, 8, 260, '2025-10-30', 'satisfactory', NULL, 'uploads/1761804426_PhotoGrid_Plus_1761804351474.jpg', NULL, '2025-10-30 13:07:07', NULL, 8, NULL),
(574, 5, 264, '2025-10-31', 'satisfactory', NULL, 'uploads/1761868023_IMG20251024130000.jpg', 'Penanaman jagung madu diwilayah sawah gede', '2025-10-31 06:47:03', NULL, 5, NULL),
(575, 5, 268, '2025-10-24', 'satisfactory', NULL, 'uploads/1761868230_IMG20251024130145.jpg', NULL, '2025-10-31 06:50:31', NULL, 5, NULL),
(576, 5, 218, '2025-10-29', 'satisfactory', NULL, 'uploads/1761868360_IMG20251029100302.jpg', NULL, '2025-10-31 06:52:40', NULL, 5, NULL),
(577, 5, 265, '2025-10-24', 'satisfactory', NULL, 'uploads/1761868529_IMG20251024130344.jpg', NULL, '2025-10-31 06:55:29', NULL, 5, NULL),
(578, 5, 270, '2025-10-31', 'satisfactory', NULL, 'uploads/1761868673_IMG20251024130758.jpg', NULL, '2025-10-31 06:57:53', NULL, 5, NULL),
(579, 5, 217, '2025-10-24', 'satisfactory', NULL, 'uploads/1761868811_IMG20251024105318_01.jpg', NULL, '2025-10-31 07:00:11', NULL, 5, NULL),
(580, 5, 272, '2025-10-24', 'satisfactory', NULL, 'uploads/1761869009_IMG20251024124832.jpg', NULL, '2025-10-31 07:03:29', NULL, 5, NULL),
(581, 8, 274, '2025-10-31', 'satisfactory', NULL, 'uploads/1761882509_PhotoGrid_Plus_1761882461731.jpg', NULL, '2025-10-31 10:48:29', NULL, 8, NULL),
(582, 8, 85, '2025-10-31', 'satisfactory', NULL, 'uploads/1761889116_PhotoGrid_Plus_1761888868687.jpg', NULL, '2025-10-31 12:38:36', NULL, 8, NULL),
(583, 8, 224, '2025-10-31', 'completed', NULL, 'uploads/1761889215_PhotoGrid_Plus_1761888926808.jpg', NULL, '2025-10-31 12:40:15', '2026-01-21 15:20:34', 8, 8),
(584, 5, 275, '2025-10-31', 'satisfactory', NULL, 'uploads/1761889492_IMG20251031111806.jpg', 'Pertumbuhan optimal namun tanda-tanda adanya serangan bulai yang terlihatbaru 2%', '2025-10-31 12:44:52', NULL, 5, NULL),
(585, 5, 276, '2025-10-31', 'satisfactory', NULL, 'uploads/1761889722_IMG20251031112156.jpg', 'Alhamdulillah pertumbuhan maksimal', '2025-10-31 12:48:42', NULL, 5, NULL),
(586, 8, 256, '2025-10-31', 'satisfactory', NULL, 'uploads/1761892032_PhotoGrid_Plus_1761891976062.jpg', NULL, '2025-10-31 13:27:13', NULL, 8, NULL),
(587, 6, 277, '2025-11-03', 'satisfactory', NULL, 'uploads/1762212777_IMG_1014.jpeg', NULL, '2025-11-04 06:32:58', NULL, 6, NULL),
(588, 6, 244, '2025-11-03', 'completed', NULL, 'uploads/1762212903_IMG_1011.jpeg', NULL, '2025-11-04 06:35:03', '2025-12-05 21:25:33', 6, 6),
(589, 6, 278, '2025-11-03', 'completed', NULL, 'uploads/1762213128_aed329a7-e7e2-4237-b0e6-5674b70a5099.jpeg', NULL, '2025-11-04 06:38:48', '2026-01-13 18:09:41', 6, 6);
INSERT INTO `demo_plot_visits` (`id`, `user_id`, `demo_plot_id`, `visit_date`, `plant_status`, `latlong`, `image_path`, `notes`, `created_datetime`, `updated_datetime`, `created_by_uid`, `updated_by_uid`) VALUES
(590, 6, 236, '2025-11-03', 'completed', NULL, 'uploads/1762213215_IMG_1006.jpeg', NULL, '2025-11-04 06:40:15', '2025-12-05 21:26:09', 6, 6),
(591, 6, 243, '2025-11-03', 'completed', NULL, 'uploads/1762213381_ae0484c9-3996-44df-bd8b-0718bbe6ba81.jpeg', NULL, '2025-11-04 06:43:01', '2026-01-13 18:10:54', 6, 6),
(592, 6, 211, '2025-11-03', 'completed', NULL, 'uploads/1762213475_IMG_0998.jpeg', NULL, '2025-11-04 06:44:36', '2026-01-13 18:11:48', 6, 6),
(593, 6, 279, '2025-11-03', 'satisfactory', NULL, 'uploads/1762213740_bdf81dfd-1ad9-4863-a74b-07501ad7b940.jpeg', NULL, '2025-11-04 06:49:00', NULL, 6, NULL),
(594, 6, 213, '2025-11-03', 'satisfactory', NULL, 'uploads/1762213834_IMG_0994.jpeg', NULL, '2025-11-04 06:50:35', NULL, 6, NULL),
(595, 6, 183, '2025-11-03', 'completed', NULL, 'uploads/1762213974_IMG_0993.jpeg', NULL, '2025-11-04 06:52:54', '2025-12-25 20:10:46', 6, 6),
(596, 6, 254, '2025-11-03', 'completed', NULL, 'uploads/1762214064_IMG_0991.jpeg', NULL, '2025-11-04 06:54:24', '2025-12-05 21:31:14', 6, 6),
(597, 7, 206, '2025-11-04', 'satisfactory', NULL, 'uploads/1762214151_1000602611.jpg', NULL, '2025-11-04 06:55:51', NULL, 7, NULL),
(598, 7, 232, '2025-11-04', 'satisfactory', NULL, 'uploads/1762214203_1000602612.jpg', NULL, '2025-11-04 06:56:43', NULL, 7, NULL),
(599, 6, 194, '2025-11-03', 'completed', NULL, 'uploads/1762214234_9639c4e1-56f1-4726-9d74-85de9c9c907e.jpeg', NULL, '2025-11-04 06:57:14', '2025-12-05 21:26:55', 6, 6),
(600, 7, 242, '2025-11-04', 'satisfactory', NULL, 'uploads/1762214255_1000602614.jpg', NULL, '2025-11-04 06:57:35', NULL, 7, NULL),
(601, 6, 230, '2025-11-03', 'completed', NULL, 'uploads/1762214313_IMG_0988.jpeg', NULL, '2025-11-04 06:58:33', '2025-12-05 21:30:31', 6, 6),
(602, 6, 280, '2025-11-03', 'satisfactory', NULL, 'uploads/1762214537_56d93a7e-752a-456b-9772-1bd0b32b308a.jpeg', NULL, '2025-11-04 07:02:17', NULL, 6, NULL),
(603, 6, 233, '2025-11-03', 'completed', NULL, 'uploads/1762214619_IMG_0981.jpeg', NULL, '2025-11-04 07:03:39', '2025-12-05 21:30:02', 6, 6),
(604, 6, 210, '2025-10-31', 'completed', NULL, 'uploads/1762215205_IMG_0825.jpeg', NULL, '2025-11-04 07:13:26', '2025-12-05 21:29:27', 6, 6),
(605, 6, 209, '2025-10-31', 'completed', NULL, 'uploads/1762218047_e9611f7a-34c7-4714-9d05-135f31d6b4c9.jpeg', NULL, '2025-11-04 08:00:47', '2025-12-05 21:27:55', 6, 6),
(606, 6, 208, '2025-10-31', 'completed', NULL, 'uploads/1762218155_b397927d-ff7d-4ef4-82ea-5d3579f3f20b.jpeg', NULL, '2025-11-04 08:02:35', '2025-11-14 09:40:16', 6, 6),
(607, 8, 258, '2025-11-06', 'completed', NULL, 'uploads/1762405980_PhotoGrid_Plus_1762405834023.jpg', NULL, '2025-11-06 12:13:01', '2026-01-21 15:20:59', 8, 8),
(608, 8, 257, '2025-11-06', 'satisfactory', NULL, 'uploads/1762406015_PhotoGrid_Plus_1762405868180.jpg', NULL, '2025-11-06 12:13:35', NULL, 8, NULL),
(609, 8, 260, '2025-11-06', 'completed', NULL, 'uploads/1762415678_PhotoGrid_Plus_1762415605855.jpg', NULL, '2025-11-06 14:54:38', '2026-01-21 15:20:07', 8, 8),
(610, 8, 259, '2025-11-06', 'completed', NULL, 'uploads/1762415710_PhotoGrid_Plus_1762415639513.jpg', NULL, '2025-11-06 14:55:11', '2026-01-21 15:19:42', 8, 8),
(611, 8, 226, '2025-11-07', 'satisfactory', NULL, 'uploads/1762490904_PhotoGrid_Plus_1762490836483.jpg', NULL, '2025-11-07 11:48:24', NULL, 8, NULL),
(612, 8, 225, '2025-11-07', 'satisfactory', NULL, 'uploads/1762490938_PhotoGrid_Plus_1762490810712.jpg', NULL, '2025-11-07 11:48:58', NULL, 8, NULL),
(613, 8, 255, '2025-11-11', 'unsatisfactory', NULL, 'uploads/1762838011_PhotoGrid_Plus_1762837873016.jpg', 'Serangan ulat lumayan besar dan gulma sudah tinggi', '2025-11-11 12:13:31', NULL, 8, NULL),
(614, 8, 281, '2025-11-11', 'completed', NULL, 'uploads/1762838115_PhotoGrid_Plus_1762837895246.jpg', NULL, '2025-11-11 12:15:15', '2026-01-21 15:19:14', 8, 8),
(615, 7, 220, '2025-11-12', 'satisfactory', NULL, 'uploads/1762948874_1000615266.jpg', NULL, '2025-11-12 19:01:14', NULL, 7, NULL),
(616, 7, 196, '2025-11-12', 'satisfactory', NULL, 'uploads/1762948986_1000615265.jpg', NULL, '2025-11-12 19:03:06', NULL, 7, NULL),
(617, 7, 282, '2025-11-12', 'satisfactory', NULL, 'uploads/1762949165_1000615267.jpg', NULL, '2025-11-12 19:06:05', NULL, 7, NULL),
(618, 5, 276, '2025-11-07', 'satisfactory', NULL, 'uploads/1762964176_IMG20251107113130.jpg', 'Pertumbuhan serempak dan tanaman aman dari serangan hpt', '2025-11-12 23:16:16', NULL, 5, NULL),
(619, 5, 275, '2025-11-07', 'satisfactory', NULL, 'uploads/1762964272_IMG20251107112721_01.jpg', 'Tanaman maksimal namun terdapat beberapa tanaman terkena bulai namun tidak banyak', '2025-11-12 23:17:53', NULL, 5, NULL),
(620, 5, 273, '2025-11-12', 'satisfactory', NULL, 'uploads/1762964502_IMG20251108135220.jpg', 'Pertumbuhan normal namun 5% terserang lalat bibit', '2025-11-12 23:21:43', NULL, 5, NULL),
(621, 5, 266, '2025-11-12', 'satisfactory', NULL, 'uploads/1762964608_IMG20251110134144.jpg', 'Tumbuh optimal dan sedang dilakukan proses penyemprotan pupuk daun', '2025-11-12 23:23:29', NULL, 5, NULL),
(622, 5, 283, '2025-11-12', 'satisfactory', NULL, 'uploads/1762964825_IMG20251110134152.jpg', 'Tumbuh dengan optimal dan sedang dilakukan penyemprotan pupuk daun', '2025-11-12 23:27:05', NULL, 5, NULL),
(623, 5, 269, '2025-11-12', 'satisfactory', NULL, 'uploads/1762964996_IMG20251108134001.jpg', 'Tanama Alhamdulillah tumbuh optimal dan pengarahan penyemprotan insektisida untuk antisipasi serangan ulat', '2025-11-12 23:29:57', NULL, 5, NULL),
(624, 5, 267, '2025-11-12', 'satisfactory', NULL, 'uploads/1762965135_IMG20251108133959_01.jpg', 'Alhamdulillah tanaman optimal dan dilakukan penyemprotan insektisida', '2025-11-12 23:32:15', NULL, 5, NULL),
(625, 5, 272, '2025-11-12', 'satisfactory', NULL, 'uploads/1762965316_IMG20251108141157.jpg', 'Tanaman Alhamdulillah maksimal', '2025-11-12 23:35:16', NULL, 5, NULL),
(626, 5, 270, '2025-11-12', 'satisfactory', NULL, 'uploads/1762965495_IMG20251108133104.jpg', 'Tanaman tumbuh subur dan sedang dilakukan penyemprotan herbisida', '2025-11-12 23:38:15', NULL, 5, NULL),
(627, 5, 265, '2025-11-12', 'satisfactory', NULL, 'uploads/1762965655_IMG20251108134121.jpg', 'Tanaman optimal namun pengairan terlalu berlebih karena air hujan terlalu tinggi', '2025-11-12 23:40:56', NULL, 5, NULL),
(628, 5, 268, '2025-11-12', 'satisfactory', NULL, 'uploads/1762965802_IMG20251108134004_01.jpg', 'Tanaman optimal dan pertumbuhan serempak', '2025-11-12 23:43:22', NULL, 5, NULL),
(629, 5, 264, '2025-11-12', 'satisfactory', NULL, 'uploads/1762966015_IMG20251108134004.jpg', NULL, '2025-11-12 23:46:55', NULL, 5, NULL),
(630, 5, 215, '2025-11-12', 'satisfactory', NULL, 'uploads/1762966103_IMG20251108134709.jpg', NULL, '2025-11-12 23:48:24', NULL, 5, NULL),
(631, 5, 214, '2025-11-12', 'satisfactory', NULL, 'uploads/1762966225_IMG20251108134628.jpg', 'Tanaman optimal dan serempak, serangan hpt sangat aman', '2025-11-12 23:50:25', NULL, 5, NULL),
(632, 5, 263, '2025-11-12', 'satisfactory', NULL, 'uploads/1762966383_IMG20251110143153.jpg', 'Tanaman tumbuh dengan optimal namun tingginya tidak serempak karena tergenang air hujan', '2025-11-12 23:53:03', NULL, 5, NULL),
(633, 5, 253, '2025-11-12', 'satisfactory', NULL, 'uploads/1762966536_IMG20251110141532.jpg', 'Tanaman serempak dan tumbuh optimal namun ada beberapa pohon yang terkena bulai', '2025-11-12 23:55:36', NULL, 5, NULL),
(634, 5, 185, '2025-11-12', 'satisfactory', NULL, 'uploads/1762966628_Picsart_25-11-12_13-39-13-872.jpg', 'Panen dan dilakukan kegiatan fieldtrip', '2025-11-12 23:57:08', NULL, 5, NULL),
(635, 5, 180, '2025-11-02', 'satisfactory', NULL, 'uploads/1762966770_IMG20251102143248.jpg', 'Panen sekaligus acara fieldtrip', '2025-11-12 23:59:31', NULL, 5, NULL),
(636, 5, 186, '2025-11-04', 'satisfactory', NULL, 'uploads/1762966929_IMG20251104133623.jpg', NULL, '2025-11-13 00:02:09', NULL, 5, NULL),
(637, 5, 186, '2025-11-05', 'satisfactory', NULL, 'uploads/1762966978_IMG20251104133026.jpg', 'Atur panen ditanggal 5', '2025-11-13 00:02:58', NULL, 5, NULL),
(638, 5, 221, '2025-10-31', 'satisfactory', NULL, 'uploads/1762967260_IMG20251031135014.jpg', 'Tanama Alhamdulillah memuaskan dan serempak pertumbuhannya', '2025-11-13 00:07:40', NULL, 5, NULL),
(639, 5, 284, '2025-11-13', 'satisfactory', NULL, 'uploads/1762967576_IMG20251031135205.jpg', 'Tanama Alhamdulillah memuaskan dan serempak pertumbuhannya', '2025-11-13 00:12:57', NULL, 5, NULL),
(640, 5, 249, '2025-11-13', 'satisfactory', NULL, 'uploads/1762967843_IMG20251108133940.jpg', NULL, '2025-11-13 00:17:24', NULL, 5, NULL),
(641, 8, 181, '2025-11-13', 'satisfactory', NULL, 'uploads/1763008948_PhotoGrid_Plus_1763008825109.jpg', NULL, '2025-11-13 11:42:28', NULL, 8, NULL),
(642, 8, 73, '2025-11-13', 'satisfactory', NULL, 'uploads/1763009042_PhotoGrid_Plus_1763008846323.jpg', NULL, '2025-11-13 11:44:02', NULL, 8, NULL),
(643, 8, 285, '2025-11-13', 'satisfactory', NULL, 'uploads/1763009278_PhotoGrid_Plus_1763008783226.jpg', NULL, '2025-11-13 11:47:58', NULL, 8, NULL),
(644, 8, 142, '2025-11-13', 'unsatisfactory', NULL, 'uploads/1763016413_PhotoGrid_Plus_1763016341806.jpg', NULL, '2025-11-13 13:46:54', NULL, 8, NULL),
(645, 8, 286, '2025-11-13', 'satisfactory', NULL, 'uploads/1763019732_IMG-20251113-WA0002.jpg', NULL, '2025-11-13 14:42:12', NULL, 8, NULL),
(646, 7, 287, '2025-11-14', 'satisfactory', NULL, 'uploads/1763084004_1000617263.jpg', NULL, '2025-11-14 08:33:24', NULL, 7, NULL),
(647, 7, 288, '2025-11-14', 'satisfactory', NULL, 'uploads/1763084065_1000617264.jpg', NULL, '2025-11-14 08:34:25', NULL, 7, NULL),
(648, 6, 289, '2025-11-14', 'completed', NULL, 'uploads/1763088332_IMG_1298.jpeg', NULL, '2025-11-14 09:45:33', '2026-01-13 18:12:23', 6, 6),
(649, 6, 290, '2025-11-13', 'completed', NULL, 'uploads/1763088567_IMG_1293.jpeg', NULL, '2025-11-14 09:49:28', '2025-12-05 21:02:39', 6, 6),
(650, 6, 148, '2025-11-13', 'completed', NULL, 'uploads/1763088664_2a0fbc60-64e7-40dd-b04f-3751b4908263.jpeg', NULL, '2025-11-14 09:51:05', '2026-01-13 18:13:10', 6, 6),
(651, 6, 291, '2025-11-10', 'satisfactory', NULL, 'uploads/1763088941_IMG_1262.jpeg', NULL, '2025-11-14 09:55:42', NULL, 6, NULL),
(652, 8, 286, '2025-11-14', 'satisfactory', NULL, 'uploads/1763098336_PhotoGrid_Plus_1763098268330.jpg', NULL, '2025-11-14 12:32:17', NULL, 8, NULL),
(653, 7, 292, '2025-11-16', 'satisfactory', NULL, 'uploads/1763274836_1000617905.jpg', NULL, '2025-11-16 13:33:56', NULL, 7, NULL),
(654, 7, 293, '2025-11-16', 'satisfactory', NULL, 'uploads/1763274889_1000619831.jpg', NULL, '2025-11-16 13:34:49', NULL, 7, NULL),
(655, 7, 294, '2025-11-16', 'satisfactory', NULL, 'uploads/1763274967_1000620128.jpg', NULL, '2025-11-16 13:36:07', NULL, 7, NULL),
(656, 7, 295, '2025-11-16', 'satisfactory', NULL, 'uploads/1763275016_1000620126.jpg', NULL, '2025-11-16 13:36:56', NULL, 7, NULL),
(657, 7, 296, '2025-11-16', 'satisfactory', NULL, 'uploads/1763275406_1000566773.jpg', NULL, '2025-11-16 13:43:26', NULL, 7, NULL),
(658, 6, 297, '2025-11-17', 'completed', NULL, 'uploads/1763464812_IMG_1351.jpeg', NULL, '2025-11-18 18:20:13', '2026-02-24 15:00:06', 6, 6),
(659, 6, 277, '2025-11-18', 'completed', NULL, 'uploads/1763464883_IMG_1360.jpeg', NULL, '2025-11-18 18:21:25', '2025-12-05 21:28:36', 6, 6),
(660, 6, 298, '2025-11-18', 'completed', NULL, 'uploads/1763465082_IMG_1364.jpeg', NULL, '2025-11-18 18:24:43', '2026-02-24 14:59:17', 6, 6),
(661, 6, 299, '2025-11-18', 'completed', NULL, 'uploads/1763465245_IMG_1356.jpeg', NULL, '2025-11-18 18:27:26', '2025-12-25 20:07:55', 6, 6),
(662, 7, 242, '2025-11-19', 'failed', NULL, 'uploads/1763514543_1000623427.jpg', 'Ke banjiran', '2025-11-19 08:09:03', NULL, 7, NULL),
(663, 7, 245, '2025-11-19', 'failed', NULL, 'uploads/1763514596_1000623427.jpg', 'Ke banjiran dan hama tikus', '2025-11-19 08:09:56', NULL, 7, NULL),
(664, 7, 238, '2025-11-19', 'failed', NULL, 'uploads/1763514642_1000623427.jpg', NULL, '2025-11-19 08:10:42', NULL, 7, NULL),
(665, 5, 300, '2025-11-14', 'satisfactory', NULL, 'uploads/1763521947_IMG20251114124107.jpg', 'Tanama Alhamdulillah memuaskan petani diarahkan untuk antisipasi supaya tanaman tidak terkena ulat', '2025-11-19 10:12:27', NULL, 5, NULL),
(666, 5, 301, '2025-11-14', 'satisfactory', NULL, 'uploads/1763522101_IMG20251114124657_01.jpg', 'Tanaman optimal namun gulma terlalu subur', '2025-11-19 10:15:01', NULL, 5, NULL),
(667, 8, 255, '2025-11-21', 'completed', NULL, 'uploads/1763695229_20251121_095608.jpg', NULL, '2025-11-21 10:20:30', '2026-01-21 15:18:57', 8, 8),
(668, 8, 302, '2025-11-21', 'completed', NULL, 'uploads/1763708206_PhotoGrid_Plus_1763707853541.jpg', NULL, '2025-11-21 13:56:46', '2026-01-21 15:18:06', 8, 8),
(669, 8, 286, '2025-11-21', 'completed', NULL, 'uploads/1763708278_PhotoGrid_Plus_1763708252436.jpg', NULL, '2025-11-21 13:57:58', '2026-01-21 15:17:32', 8, 8),
(670, 6, 304, '2025-11-25', 'satisfactory', NULL, 'uploads/1764127073_IMG_1588.jpeg', NULL, '2025-11-26 10:17:53', NULL, 6, NULL),
(671, 6, 305, '2025-11-26', 'satisfactory', NULL, 'uploads/1764127215_IMG_1637.jpeg', NULL, '2025-11-26 10:20:16', NULL, 6, NULL),
(672, 8, 225, '2025-11-26', 'completed', NULL, 'uploads/1764135234_PhotoGrid_Plus_1764134720943.jpg', NULL, '2025-11-26 12:33:55', '2026-01-21 15:18:33', 8, 8),
(673, 8, 226, '2025-11-26', 'completed', NULL, 'uploads/1764135417_PhotoGrid_Plus_1764134778373.jpg', NULL, '2025-11-26 12:36:57', '2026-01-21 15:17:01', 8, 8),
(674, 8, 142, '2025-11-26', 'satisfactory', NULL, 'uploads/1764135559_PhotoGrid_Plus_1764134869605.jpg', NULL, '2025-11-26 12:39:19', NULL, 8, NULL),
(675, 8, 306, '2025-11-26', 'completed', NULL, 'uploads/1764135777_PhotoGrid_Plus_1764134965075.jpg', NULL, '2025-11-26 12:42:57', '2026-01-21 15:16:33', 8, 8),
(676, 8, 285, '2025-11-26', 'completed', NULL, 'uploads/1764135938_PhotoGrid_Plus_1764135040014.jpg', NULL, '2025-11-26 12:45:38', '2026-01-21 15:16:02', 8, 8),
(677, 8, 181, '2025-11-26', 'satisfactory', NULL, 'uploads/1764136047_PhotoGrid_Plus_1764135137568.jpg', NULL, '2025-11-26 12:47:27', NULL, 8, NULL),
(678, 6, 279, '2025-11-26', 'completed', NULL, 'uploads/1764142661_IMG_1645.jpeg', NULL, '2025-11-26 14:37:42', '2026-01-13 18:14:49', 6, 6),
(679, 6, 213, '2025-11-26', 'completed', NULL, 'uploads/1764142734_IMG_1644.jpeg', NULL, '2025-11-26 14:38:55', '2025-12-25 20:06:52', 6, 6),
(680, 8, 256, '2025-11-26', 'completed', NULL, 'uploads/1764146813_PhotoGrid_Plus_1764146649122.jpg', NULL, '2025-11-26 15:46:54', '2026-01-21 15:15:29', 8, 8),
(681, 8, 274, '2025-11-26', 'satisfactory', NULL, 'uploads/1764146982_PhotoGrid_Plus_1764146716662.jpg', NULL, '2025-11-26 15:49:43', NULL, 8, NULL),
(682, 8, 307, '2025-11-26', 'satisfactory', NULL, 'uploads/1764147146_PhotoGrid_Plus_1764146757041.jpg', NULL, '2025-11-26 15:52:26', NULL, 8, NULL),
(683, 5, 284, '2025-11-26', 'satisfactory', NULL, 'uploads/1764300033_IMG20251126095953.jpg', 'Pertumbuhan optimal namun tanaman jagung reva terkena kresek dibanding jagung madu dan exotic disatu hamparan yang sama', '2025-11-28 10:20:33', NULL, 5, NULL),
(684, 5, 284, '2025-11-28', 'satisfactory', NULL, 'uploads/1764300060_IMG20251126100021.jpg', NULL, '2025-11-28 10:21:00', NULL, 5, NULL),
(685, 5, 249, '2025-11-28', 'satisfactory', NULL, 'uploads/1764300189_IMG20251125122844.jpg', 'Pertumbuhan alhamdulillah serempak namun posisi lahan sering tergenang air hujan', '2025-11-28 10:23:09', NULL, 5, NULL),
(686, 5, 253, '2025-11-28', 'satisfactory', NULL, 'uploads/1764300504_IMG20251121095216.jpg', NULL, '2025-11-28 10:28:24', NULL, 5, NULL),
(687, 5, 264, '2025-11-28', 'satisfactory', NULL, 'uploads/1764300568_IMG20251121095401.jpg', NULL, '2025-11-28 10:29:28', NULL, 5, NULL),
(688, 5, 265, '2025-11-25', 'satisfactory', NULL, 'uploads/1764300636_IMG20251125122841.jpg', NULL, '2025-11-28 10:30:36', NULL, 5, NULL),
(689, 5, 270, '2025-11-28', 'satisfactory', NULL, 'uploads/1764300725_IMG20251125140530.jpg', NULL, '2025-11-28 10:32:05', NULL, 5, NULL),
(690, 5, 275, '2025-11-28', 'satisfactory', NULL, 'uploads/1764300788_IMG20251121130211.jpg', NULL, '2025-11-28 10:33:08', NULL, 5, NULL),
(691, 5, 283, '2025-11-28', 'satisfactory', NULL, 'uploads/1764300917_IMG20251125140539.jpg', NULL, '2025-11-28 10:35:18', NULL, 5, NULL),
(692, 5, 250, '2025-11-28', 'satisfactory', NULL, 'uploads/1764301049_IMG20251125140540.jpg', NULL, '2025-11-28 10:37:29', NULL, 5, NULL),
(693, 5, 276, '2025-11-28', 'satisfactory', NULL, 'uploads/1764301108_IMG20251121130531.jpg', NULL, '2025-11-28 10:38:28', NULL, 5, NULL),
(694, 5, 216, '2025-11-26', 'satisfactory', NULL, 'uploads/1764301194_Picsart_25-11-26_09-36-01-326.jpg', NULL, '2025-11-28 10:39:55', NULL, 5, NULL),
(695, 6, 308, '2025-11-28', 'completed', NULL, 'uploads/1764327902_IMG_1715.jpeg', NULL, '2025-11-28 18:05:02', '2026-02-24 14:58:36', 6, 6),
(696, 7, 309, '2025-12-01', 'satisfactory', NULL, 'uploads/1764579417_1000639995.jpg', NULL, '2025-12-01 15:56:57', NULL, 7, NULL),
(697, 7, 310, '2025-12-01', 'satisfactory', NULL, 'uploads/1764581098_1000627171.jpg', NULL, '2025-12-01 16:24:58', NULL, 7, NULL),
(698, 6, 311, '2025-12-02', 'completed', NULL, 'uploads/1764631979_IMG-20251202-WA0000.jpg', NULL, '2025-12-02 06:32:59', '2026-02-24 14:57:59', 6, 6),
(699, 8, 312, '2025-12-04', 'satisfactory', NULL, 'uploads/1764821011_PhotoGrid_Plus_1764820835786.jpg', NULL, '2025-12-04 11:03:31', NULL, 8, NULL),
(700, 5, 275, '2025-12-01', 'satisfactory', NULL, 'uploads/1764911679_IMG-20251201-WA0026.jpg', 'Kontrol pertumbuhan jagung manis madu dan meng agendakan petik putren tanggal 4,pertumbuhan Alhamdulillah serempak dan optimal', '2025-12-05 12:14:39', NULL, 5, NULL),
(701, 5, 284, '2025-12-02', 'satisfactory', NULL, 'uploads/1764911923_IMG20251202113337.jpg', 'Pertumbuhan dari ke 3 jenis, madu, Reva dan kompetitor ekotic pertumbuhan yang paling optimal madu dan Reva. Untuk kompetitor DB kalah dan banyak bulainya, buahnya kecil dan tanaman kena kresek', '2025-12-05 12:18:44', NULL, 5, NULL),
(702, 5, 253, '2025-12-03', 'satisfactory', NULL, 'uploads/1764912264_IMG20251203103849.jpg', 'Pertumbuhan 9 bungkus aman namun yang 1 bungkus terendam air dan layu. Untuk yang 9 bungkus Aman merata dan sedang dilakukan pemetikan putren', '2025-12-05 12:24:25', NULL, 5, NULL),
(703, 5, 313, '2025-12-03', 'satisfactory', NULL, 'uploads/1764912738_IMG20251203111303.jpg', 'Pertumbuhan optimal dan sedang proses masuk kefase generatif', '2025-12-05 12:32:18', NULL, 5, NULL),
(704, 5, 301, '2025-12-03', 'satisfactory', NULL, 'uploads/1764912855_IMG20251203133942.jpg', 'Pertumbuhan seragam namun siwil masih keluar dan petani mengeluh karena tumbuhnya 2x', '2025-12-05 12:34:15', NULL, 5, NULL),
(705, 5, 300, '2025-12-03', 'satisfactory', NULL, 'uploads/1764912988_IMG20251203132040.jpg', 'Pertumbuhan baik namun untuk jarak tanam terlalu rapat, koordinasi untuk agenda pemetikan jagung putren', '2025-12-05 12:36:28', NULL, 5, NULL),
(706, 5, 314, '2025-12-03', 'satisfactory', NULL, 'uploads/1764913168_IMG20251203111845.jpg', NULL, '2025-12-05 12:39:28', NULL, 5, NULL),
(707, 5, 251, '2025-12-03', 'satisfactory', NULL, 'uploads/1764913245_IMG20251203111439.jpg', NULL, '2025-12-05 12:40:45', NULL, 5, NULL),
(708, 5, 263, '2025-12-03', 'satisfactory', NULL, 'uploads/1764913408_IMG20251203111847.jpg', NULL, '2025-12-05 12:43:28', NULL, 5, NULL),
(709, 5, 217, '2025-11-25', 'satisfactory', NULL, 'uploads/1764913543_IMG20251125140646.jpg', NULL, '2025-12-05 12:45:43', NULL, 5, NULL),
(710, 7, 282, '2025-12-05', 'completed', NULL, 'uploads/1764941310_1000645717.jpg', NULL, '2025-12-05 20:28:30', NULL, 7, NULL),
(711, 7, 315, '2025-12-05', 'satisfactory', NULL, 'uploads/1764941428_1000645714.jpg', NULL, '2025-12-05 20:30:28', NULL, 7, NULL),
(712, 7, 316, '2025-12-05', 'satisfactory', NULL, 'uploads/1764941559_1000645718.jpg', NULL, '2025-12-05 20:32:39', NULL, 7, NULL),
(713, 7, 317, '2025-12-05', 'satisfactory', NULL, 'uploads/1764941624_1000645716.jpg', NULL, '2025-12-05 20:33:34', '2025-12-05 20:33:44', 7, 7),
(714, 6, 291, '2025-12-01', 'completed', NULL, 'uploads/1764943516_IMG_1769.jpeg', NULL, '2025-12-05 21:05:16', '2026-01-13 18:07:22', 6, 6),
(715, 7, 318, '2025-12-05', 'satisfactory', NULL, 'uploads/1764943597_1000645753.jpg', NULL, '2025-12-05 21:06:37', NULL, 7, NULL),
(716, 6, 319, '2025-12-03', 'completed', NULL, 'uploads/1764943776_IMG_1911.jpeg', NULL, '2025-12-05 21:09:36', '2026-01-13 18:06:28', 6, 6),
(717, 6, 320, '2025-12-02', 'satisfactory', NULL, 'uploads/1764943918_IMG_1817.jpeg', NULL, '2025-12-05 21:11:58', NULL, 6, NULL),
(718, 7, 287, '2025-12-05', 'unsatisfactory', NULL, 'uploads/1764943998_1000645762.jpg', NULL, '2025-12-05 21:13:19', NULL, 7, NULL),
(719, 6, 241, '2025-12-03', 'completed', NULL, 'uploads/1764944018_IMG_1563.jpeg', NULL, '2025-12-05 21:13:38', '2025-12-25 20:05:50', 6, 6),
(720, 7, 288, '2025-12-05', 'unsatisfactory', NULL, 'uploads/1764944030_1000645762.jpg', NULL, '2025-12-05 21:13:51', NULL, 7, NULL),
(721, 6, 321, '2025-12-03', 'completed', NULL, 'uploads/1764944156_IMG_1793.jpeg', NULL, '2025-12-05 21:15:56', '2026-01-13 18:05:14', 6, 6),
(722, 7, 205, '2025-12-05', 'completed', NULL, 'uploads/1764944175_1000645765.jpg', NULL, '2025-12-05 21:16:15', NULL, 7, NULL),
(723, 7, 196, '2025-12-05', 'completed', NULL, 'uploads/1764944218_1000645766.jpg', NULL, '2025-12-05 21:16:58', NULL, 7, NULL),
(724, 7, 220, '2025-12-05', 'completed', NULL, 'uploads/1764944248_1000645765.jpg', NULL, '2025-12-05 21:17:28', NULL, 7, NULL),
(725, 7, 232, '2025-12-05', 'completed', NULL, 'uploads/1764944274_1000645765.jpg', NULL, '2025-12-05 21:17:54', '2025-12-05 21:18:21', 7, 7),
(726, 6, 168, '2025-11-20', 'completed', NULL, 'uploads/1764944298_IMG_1429.jpeg', NULL, '2025-12-05 21:18:18', '2025-12-25 20:05:08', 6, 6),
(727, 7, 322, '2025-12-05', 'satisfactory', NULL, 'uploads/1764944422_1000645770.jpg', NULL, '2025-12-05 21:20:22', NULL, 7, NULL),
(728, 6, 305, '2025-12-15', 'completed', NULL, 'uploads/1765873666_IMG_2168.jpeg', NULL, '2025-12-16 15:27:46', '2026-01-13 18:04:30', 6, 6),
(729, 6, 323, '2025-12-15', 'satisfactory', NULL, 'uploads/1766013642_IMG_2116.jpeg', NULL, '2025-12-18 06:20:42', NULL, 6, NULL),
(730, 6, 324, '2025-12-17', 'satisfactory', NULL, 'uploads/1766013797_0bbca3f7-db59-49cc-8c8d-8c42d6fb5609.jpeg', NULL, '2025-12-18 06:23:17', NULL, 6, NULL),
(731, 6, 325, '2025-12-16', 'satisfactory', NULL, 'uploads/1766013916_7a2c6fa5-dc43-4621-be92-2d404f265b80.jpeg', NULL, '2025-12-18 06:25:16', NULL, 6, NULL),
(732, 6, 304, '2025-12-22', 'satisfactory', NULL, 'uploads/1766668769_IMG_2426.jpeg', NULL, '2025-12-25 20:19:30', NULL, 6, NULL),
(733, 6, 326, '2025-12-25', 'satisfactory', NULL, 'uploads/1766669018_e6badcbd-9a46-40d5-826b-2b7c191fe1a1.jpeg', NULL, '2025-12-25 20:23:38', NULL, 6, NULL),
(734, 7, 248, '2025-12-25', 'satisfactory', NULL, 'uploads/1766669091_1000669850.jpg', NULL, '2025-12-25 20:24:52', NULL, 7, NULL),
(735, 7, 309, '2025-12-25', 'satisfactory', NULL, 'uploads/1766669160_1000669848.jpg', NULL, '2025-12-25 20:26:00', NULL, 7, NULL),
(736, 7, 292, '2025-12-25', 'satisfactory', NULL, 'uploads/1766669266_1000669849.jpg', NULL, '2025-12-25 20:27:46', NULL, 7, NULL),
(737, 6, 280, '2025-12-30', 'completed', NULL, 'uploads/1767060126_IMG_2423.jpeg', NULL, '2025-12-30 09:02:06', '2026-02-24 14:57:04', 6, 6),
(738, 6, 327, '2025-12-30', 'satisfactory', NULL, 'uploads/1767061328_807bf491-70f1-4b3d-ad3b-7b5ac7d19c2d.jpeg', NULL, '2025-12-30 09:22:08', NULL, 6, NULL),
(739, 5, 265, '2025-12-30', 'satisfactory', NULL, 'uploads/1767083618_IMG20251221123749.jpg', 'Pertumbuhan optimal dan dipanen untuk momen tahun baruan dan setelah tahun baruan', '2025-12-30 15:33:38', NULL, 5, NULL),
(740, 5, 267, '2025-12-22', 'satisfactory', NULL, 'uploads/1767083732_IMG20251221125226.jpg', 'Proses pemetikan putren jagung manis madu', '2025-12-30 15:35:32', NULL, 5, NULL),
(741, 5, 267, '2025-12-30', 'satisfactory', NULL, 'uploads/1767083825_IMG20251221130119.jpg', 'Kontrol pertumbuhan jagung madu untuk panen setelah tahun baru', '2025-12-30 15:37:06', NULL, 5, NULL),
(742, 5, 276, '2025-12-29', 'satisfactory', NULL, 'uploads/1767083965_IMG20251229123402.jpg', 'Kawal panenan jagung reva alhamdulillah hasil masih optimal 1 bungkus rata-rata keluar 5 kwintal', '2025-12-30 15:39:25', NULL, 5, NULL),
(743, 5, 253, '2025-12-20', 'satisfactory', NULL, 'uploads/1767084107_IMG20251220122708.jpg', 'Pemanenan per bungkus masih bertahan 4 kwintal', '2025-12-30 15:41:47', NULL, 5, NULL),
(744, 5, 275, '2025-12-15', 'satisfactory', NULL, 'uploads/1767084303_Screenshot_2025-12-30-15-44-50-34_40deb401b9ffe8e1df2f1cc5ba480b12.jpg', 'Proses cek lahan dan persiapan atur jadwal pemanenan jagung manis madu\r\n\r\nTonase putren 3 ton \r\nTonase panenan buah 11 ton', '2025-12-30 15:45:03', NULL, 5, NULL),
(745, 6, 328, '2026-01-07', 'satisfactory', NULL, 'uploads/1767789328_IMG_3077.jpeg', NULL, '2026-01-07 19:35:28', NULL, 6, NULL),
(746, 6, 304, '2026-01-07', 'completed', NULL, 'uploads/1767789417_IMG_3092.jpeg', NULL, '2026-01-07 19:36:58', '2026-02-24 14:56:30', 6, 6),
(747, 6, 327, '2026-01-08', 'satisfactory', NULL, 'uploads/1767841868_IMG_3103.jpeg', NULL, '2026-01-08 10:11:08', NULL, 6, NULL),
(748, 6, 329, '2026-01-12', 'satisfactory', NULL, 'uploads/1768194184_IMG_3203.jpeg', NULL, '2026-01-12 12:03:04', NULL, 6, NULL),
(749, 6, 320, '2026-01-12', 'satisfactory', NULL, 'uploads/1768194255_IMG_3206.jpeg', NULL, '2026-01-12 12:04:15', NULL, 6, NULL),
(750, 6, 330, '2026-01-13', 'satisfactory', NULL, 'uploads/1768302203_IMG_3260.jpeg', NULL, '2026-01-13 18:03:23', NULL, 6, NULL),
(751, 7, 318, '2026-01-15', 'satisfactory', NULL, 'uploads/1768481123_1000697277.jpg', NULL, '2026-01-15 19:45:24', NULL, 7, NULL),
(752, 7, 316, '2026-01-14', 'satisfactory', NULL, 'uploads/1768481224_1000697276.jpg', NULL, '2026-01-15 19:47:04', NULL, 7, NULL),
(753, 7, 317, '2026-01-15', 'satisfactory', NULL, 'uploads/1768481288_1000697275.jpg', NULL, '2026-01-15 19:48:08', NULL, 7, NULL),
(754, 7, 331, '2026-01-15', 'satisfactory', NULL, 'uploads/1768481373_1000697274.jpg', NULL, '2026-01-15 19:49:33', NULL, 7, NULL),
(755, 7, 296, '2026-01-15', 'completed', NULL, 'uploads/1768481426_1000697278.jpg', NULL, '2026-01-15 19:50:27', NULL, 7, NULL),
(756, 7, 322, '2026-01-15', 'satisfactory', NULL, 'uploads/1768481574_1000697281.jpg', NULL, '2026-01-15 19:52:54', NULL, 7, NULL),
(757, 7, 334, '2026-01-15', 'satisfactory', NULL, 'uploads/1768482001_1000697286.jpg', NULL, '2026-01-15 20:00:01', NULL, 7, NULL),
(758, 8, 307, '2026-01-21', 'satisfactory', NULL, 'uploads/1768982920_PhotoGrid_Plus_1768982835045.jpg', NULL, '2026-01-21 15:08:40', NULL, 8, NULL),
(759, 8, 342, '2026-01-21', 'satisfactory', NULL, 'uploads/1768982998_PhotoGrid_Plus_1768982871146.jpg', NULL, '2026-01-21 15:09:58', NULL, 8, NULL),
(760, 7, 343, '2026-01-21', 'satisfactory', NULL, 'uploads/1768996445_1000703181.jpg', NULL, '2026-01-21 18:54:05', NULL, 7, NULL),
(761, 5, 332, '2026-01-22', 'satisfactory', '-6.8788626,108.7249007', 'uploads/1769056752_IMG20260121115050.jpg', 'Db h72 baik namun tidak terkejar karena jarak 10 hst dengan jagung madu', '2026-01-22 11:39:13', NULL, 5, NULL),
(762, 5, 333, '2026-01-22', 'satisfactory', NULL, 'uploads/1769057276_IMG20260121115804.jpg', 'Db madu 80% dan disulam h72', '2026-01-22 11:47:57', NULL, 5, NULL),
(763, 5, 335, '2026-01-22', 'satisfactory', '-6.8802068,108.7216765', 'uploads/1769057422_IMG20260121123447.jpg', 'Db h72 mulai muncul umur 3 hst', '2026-01-22 11:50:22', NULL, 5, NULL),
(764, 5, 336, '2026-01-22', 'satisfactory', '-6.9157723,108.7398139', 'uploads/1769061127_IMG20260121130415.jpg', 'Cek daya rumbuh jagung h72 baru 60%', '2026-01-22 12:52:08', NULL, 5, NULL),
(765, 5, 337, '2026-01-22', 'satisfactory', NULL, 'uploads/1769061498_IMG20260122122142.jpg', 'Cek lahan l7 penanaman hari selasa dilahan pak kadiro', '2026-01-22 12:58:19', NULL, 5, NULL),
(766, 5, 352, '2025-12-15', 'satisfactory', NULL, 'uploads/1769438896_IMG-20260126-WA0068.jpg', NULL, '2026-01-26 21:48:16', NULL, 5, NULL),
(767, 5, 352, '2026-01-16', 'satisfactory', NULL, 'uploads/1769439640_IMG20251108141152.jpg', NULL, '2026-01-26 22:00:40', NULL, 5, NULL),
(768, 5, 352, '2026-01-24', 'satisfactory', NULL, 'uploads/1769439807_IMG20260124083548.jpg', 'Perawatan dan pengoptimalan buah dengan membuang putren dan dilakukan penyemprotan pembesar buah', '2026-01-26 22:03:27', NULL, 5, NULL),
(769, 5, 340, '2026-01-24', 'satisfactory', NULL, 'uploads/1769439930_IMG20260124083307.jpg', 'Kawal pertumbuhan jagung lilac dan mencari info pembayaran penanaman jagung hibrix-72', '2026-01-26 22:05:30', NULL, 5, NULL),
(770, 5, 349, '2026-01-26', 'satisfactory', NULL, 'uploads/1769440043_IMG20260124091449.jpg', 'Cek daya tumbuh jagung lilac', '2026-01-26 22:07:24', NULL, 5, NULL),
(771, 5, 351, '2026-01-26', 'satisfactory', NULL, 'uploads/1769440358_IMG20260124091558.jpg', NULL, '2026-01-26 22:12:39', NULL, 5, NULL),
(772, 5, 336, '2026-01-26', 'satisfactory', NULL, 'uploads/1769440528_IMG20260126105810.jpg', 'Cek pertumbuhan jagung h72 dan atur jadwal proses pemupukan pertama', '2026-01-26 22:15:29', NULL, 5, NULL),
(773, 5, 337, '2026-01-26', 'satisfactory', NULL, 'uploads/1769440631_IMG20260122120253.jpg', 'Cek pertumbuhan jagung h72 dilahan mas bagas binaan pak kadiro', '2026-01-26 22:17:12', NULL, 5, NULL),
(774, 5, 335, '2026-01-26', 'satisfactory', NULL, 'uploads/1769440729_IMG20260126105233.jpg', 'Cek pertumbuhan jagung h72 dan persiapan pemupukan pertama', '2026-01-26 22:18:50', NULL, 5, NULL),
(775, 5, 333, '2026-01-21', 'satisfactory', NULL, 'uploads/1769440822_IMG20260121115047.jpg', NULL, '2026-01-26 22:20:22', NULL, 5, NULL),
(776, 5, 332, '2026-01-26', 'satisfactory', '-6.6928954,108.4976508', 'uploads/1769440946_IMG20260121115802.jpg', 'Sulaman h72 tertinggal karena jarak sulaman hampir beda 1 minggu. Namun sulaman tetap tumbuh 75%', '2026-01-26 22:22:27', NULL, 5, NULL),
(777, 5, 354, '2026-01-22', 'satisfactory', NULL, 'uploads/1769441589_IMG20260122132723.jpg', NULL, '2026-01-26 22:33:10', NULL, 5, NULL),
(778, 5, 355, '2026-01-26', 'satisfactory', NULL, 'uploads/1769441829_IMG20260122130722.jpg', NULL, '2026-01-26 22:37:09', NULL, 5, NULL),
(779, 6, 330, '2026-02-09', 'satisfactory', NULL, 'uploads/1770606041_IMG_4234.jpeg', NULL, '2026-02-09 10:00:41', NULL, 6, NULL),
(780, 6, 357, '2026-02-09', 'satisfactory', NULL, 'uploads/1770606224_IMG_4241.jpeg', NULL, '2026-02-09 10:03:44', NULL, 6, NULL),
(781, 6, 358, '2026-02-10', 'satisfactory', NULL, 'uploads/1770901010_IMG_4255.jpeg', NULL, '2026-02-12 19:56:50', NULL, 6, NULL),
(782, 8, 359, '2026-02-16', 'satisfactory', NULL, 'uploads/1771231568_PhotoGrid_Plus_1771227688329.jpg', NULL, '2026-02-16 15:46:08', NULL, 8, NULL),
(783, 5, 344, '2026-02-18', 'satisfactory', NULL, 'uploads/1771469424_IMG-20260219-WA0039.jpg', 'Pertumbuhan untuk saat ini masih aman dan semoga performa pertumbuhanya makin bagus', '2026-02-19 09:50:25', NULL, 5, NULL),
(784, 5, 360, '2026-02-18', 'satisfactory', NULL, 'uploads/1771469574_IMG20260218133138.jpg', 'Tanaman sudah \r\nTumbuh dengan baik', '2026-02-19 09:52:54', NULL, 5, NULL),
(785, 5, 350, '2026-02-07', 'satisfactory', NULL, 'uploads/1771469718_IMG20260207144138.jpg', NULL, '2026-02-19 09:55:19', NULL, 5, NULL),
(786, 5, 351, '2026-02-19', 'satisfactory', NULL, 'uploads/1771469794_IMG20260207144609.jpg', NULL, '2026-02-19 09:56:35', NULL, 5, NULL),
(787, 5, 349, '2026-02-07', 'satisfactory', NULL, 'uploads/1771469923_IMG20260207144933.jpg', 'Dilakukan penyemprotan ulat dan pertumbuhn supaya tanaman tumbuh optimal', '2026-02-19 09:58:44', NULL, 5, NULL),
(788, 5, 352, '2026-02-10', 'satisfactory', NULL, 'uploads/1771470105_IMG20260210121444.jpg', 'Proses pemetikan dan pengawalan penanaman ulang', '2026-02-19 10:01:46', NULL, 5, NULL),
(789, 5, 361, '2026-02-19', 'satisfactory', NULL, 'uploads/1771470318_IMG20260207144024.jpg', NULL, '2026-02-19 10:05:18', NULL, 5, NULL),
(790, 5, 362, '2026-02-18', 'satisfactory', NULL, 'uploads/1771471050_IMG20260218133133.jpg', NULL, '2026-02-19 10:17:31', NULL, 5, NULL),
(791, 5, 346, '2026-02-12', 'satisfactory', NULL, 'uploads/1771471253_IMG20260212105957.jpg', NULL, '2026-02-19 10:20:53', NULL, 5, NULL),
(792, 5, 364, '2026-02-18', 'satisfactory', NULL, 'uploads/1771471518_IMG20260218111402.jpg', NULL, '2026-02-19 10:25:19', NULL, 5, NULL),
(793, 6, 365, '2026-02-20', 'satisfactory', NULL, 'uploads/1771570850_IMG_4602.jpeg', NULL, '2026-02-20 14:00:50', NULL, 6, NULL),
(794, 5, 366, '2026-02-20', 'satisfactory', NULL, 'uploads/1771599782_IMG20260220112314.jpg', 'Pertumbuhan alhamdulillah bagus dan persiapan pemupukan pertama', '2026-02-20 22:03:02', NULL, 5, NULL),
(795, 5, 367, '2026-02-20', 'satisfactory', NULL, 'uploads/1771600036_IMG20260220140930.jpg', 'Cek pertumbuhan jagung h72', '2026-02-20 22:07:17', NULL, 5, NULL),
(796, 6, 368, '2026-02-23', 'satisfactory', NULL, 'uploads/1771821244_IMG_4634.jpeg', NULL, '2026-02-23 11:34:05', NULL, 6, NULL),
(797, 7, 343, '2026-02-24', 'satisfactory', NULL, 'uploads/1771944837_1000742841.jpg', NULL, '2026-02-24 21:53:58', NULL, 7, NULL),
(798, 7, 331, '2026-02-24', 'satisfactory', NULL, 'uploads/1771944932_1000743309.jpg', NULL, '2026-02-24 21:55:32', NULL, 7, NULL),
(799, 7, 369, '2026-02-24', 'satisfactory', NULL, 'uploads/1771945057_1000743308.jpg', NULL, '2026-02-24 21:57:38', NULL, 7, NULL),
(800, 7, 370, '2026-02-24', 'satisfactory', NULL, 'uploads/1771945130_1000743358.jpg', NULL, '2026-02-24 21:58:50', NULL, 7, NULL),
(801, 5, 371, '2026-03-02', 'satisfactory', NULL, 'uploads/1772429909_IMG20260302121010.jpg', 'Cek pertumbuhan jagung h72 dilahan pa sodik umur 17 hst tumpangsari degan tanaman kangngkung alhamdulillah pertumbuhan bagus', '2026-03-02 12:38:29', NULL, 5, NULL),
(802, 5, 371, '2026-03-02', 'satisfactory', NULL, 'uploads/1772429937_IMG20260302120253.jpg', NULL, '2026-03-02 12:38:57', NULL, 5, NULL),
(803, 5, 346, '2026-03-02', 'satisfactory', NULL, 'uploads/1772430012_IMG20260302121128.jpg', 'Cek pertumbuhan jagung h72 proses pemetikan putren dihulubanteng cirebon', '2026-03-02 12:40:12', NULL, 5, NULL),
(804, 5, 364, '2026-02-27', 'satisfactory', '-6.8860254,108.7227521', 'uploads/1772430145_IMG20260227133700.jpg', 'Cek perkembagan tanaman jagung h72 dan penanganan hpt ulat menggunakan obat emacel', '2026-03-02 12:42:26', NULL, 5, NULL),
(805, 5, 372, '2026-02-27', 'satisfactory', NULL, 'uploads/1772430356_IMG20260227105546.jpg', 'Cek perkembagan jagung h72 cek mengenai daya tumbuh dan keseragaman', '2026-03-02 12:45:56', NULL, 5, NULL),
(806, 6, 373, '2026-03-02', 'satisfactory', NULL, 'uploads/1772492988_IMG_4797.jpeg', NULL, '2026-03-03 06:09:48', NULL, 6, NULL),
(807, 6, 374, '2026-03-02', 'satisfactory', NULL, 'uploads/1772493195_IMG_4790.jpeg', NULL, '2026-03-03 06:13:15', NULL, 6, NULL),
(808, 6, 375, '2026-03-02', 'satisfactory', NULL, 'uploads/1772592429_IMG_4773.jpeg', NULL, '2026-03-04 09:47:09', NULL, 6, NULL),
(809, 6, 376, '2026-03-02', 'satisfactory', NULL, 'uploads/1772592565_IMG_4765.jpeg', NULL, '2026-03-04 09:49:26', NULL, 6, NULL),
(810, 8, 377, '2026-03-04', 'satisfactory', NULL, 'uploads/1772603025_PhotoGrid_Plus_1772602844914.jpg', NULL, '2026-03-04 12:43:45', NULL, 8, NULL),
(811, 8, 342, '2026-03-04', 'satisfactory', NULL, 'uploads/1772614335_PhotoGrid_Plus_1772614250220.jpg', NULL, '2026-03-04 15:52:15', NULL, 8, NULL),
(812, 8, 378, '2026-03-04', 'satisfactory', NULL, 'uploads/1772614461_PhotoGrid_Plus_1772614291931.jpg', NULL, '2026-03-04 15:54:21', NULL, 8, NULL),
(813, 8, 379, '2026-03-05', 'satisfactory', NULL, 'uploads/1772691327_PhotoGrid_Plus_1772691103081.jpg', NULL, '2026-03-05 13:15:27', NULL, 8, NULL),
(814, 8, 380, '2026-03-09', 'satisfactory', NULL, 'uploads/1773048931_PhotoGrid_Plus_1773048787855.jpg', NULL, '2026-03-09 16:35:31', NULL, 8, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventory_logs`
--

CREATE TABLE `inventory_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED DEFAULT NULL,
  `customer_id` bigint(20) UNSIGNED DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `check_date` date NOT NULL,
  `area` varchar(255) NOT NULL,
  `lot_package` varchar(255) NOT NULL,
  `quantity` decimal(8,3) NOT NULL,
  `base_quantity` mediumint(8) UNSIGNED DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_datetime` datetime DEFAULT NULL,
  `updated_datetime` datetime DEFAULT NULL,
  `created_by_uid` bigint(20) UNSIGNED DEFAULT NULL,
  `updated_by_uid` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inventory_logs`
--

INSERT INTO `inventory_logs` (`id`, `product_id`, `customer_id`, `user_id`, `check_date`, `area`, `lot_package`, `quantity`, `base_quantity`, `notes`, `created_datetime`, `updated_datetime`, `created_by_uid`, `updated_by_uid`) VALUES
(3, 2, 38, 8, '2025-08-06', 'West Java', 'MJ52A1021', 0.000, 0, NULL, '2025-08-10 10:47:31', '2025-09-29 13:41:01', 8, 8),
(4, 8, 6, 2, '2025-09-17', 'West Java', '01020624', 0.000, 0, 'Exp APRIL 2026', '2025-08-10 21:32:22', '2025-09-17 19:35:42', 2, 2),
(5, 8, 6, 2, '2025-09-17', 'West Java', '01030225', 0.000, 0, 'Exp Feb 2026', '2025-08-10 21:33:36', '2025-09-17 19:35:24', 2, 2),
(6, 8, 6, 2, '2025-09-17', 'West Java', '01010125', 0.000, 0, 'Exp Feb 2026', '2025-08-10 21:34:49', '2025-09-17 19:35:02', 2, 2),
(7, 6, 64, 6, '2025-11-14', 'West Java', '03B070325', 0.100, 5, NULL, '2025-08-11 08:28:39', '2025-11-14 07:39:47', 6, 6),
(8, 5, 64, 6, '2025-11-14', 'West Java', 'MSEF1A0024', 0.100, 5, NULL, '2025-08-11 08:30:05', '2025-11-14 07:39:39', 6, 6),
(9, 8, 107, 6, '2025-11-14', 'West Java', '01|010125', 0.000, 0, NULL, '2025-08-11 10:14:01', '2025-11-14 07:30:58', 6, 6),
(10, 6, 107, 6, '2025-11-14', 'West Java', '03B180625', 0.000, 0, NULL, '2025-08-11 10:15:10', '2025-11-14 07:30:44', 6, 6),
(11, 11, 107, 6, '2025-11-14', 'West Java', '230711070', 0.000, 0, NULL, '2025-08-11 10:16:15', '2025-11-14 07:30:34', 6, 6),
(12, 2, 6, 2, '2025-09-17', 'West Java', 'MJ52A105', 0.000, 0, 'plan return low germ', '2025-08-11 12:04:22', '2025-09-17 19:33:10', 2, 2),
(13, 2, 6, 2, '2025-08-10', 'West Java', 'MJ52A1008', 0.000, 0, 'plan return exp 30  mei', '2025-08-11 12:05:10', '2025-09-17 19:32:54', 2, 2),
(14, 2, 6, 2, '2025-09-17', 'West Java', 'MJ52A1009', 0.500, 0, 'plan return exp  30 mei', '2025-08-11 12:06:09', '2025-09-17 19:32:26', 2, 2),
(15, 11, 6, 2, '2025-10-17', 'West Java', '230711070', 0.000, 0, NULL, '2025-08-11 12:10:08', '2025-10-17 12:15:14', 2, 2),
(16, 5, 6, 2, '2025-09-17', 'West Java', 'MSEF1A0024', 4.000, 200, NULL, '2025-08-11 12:11:38', '2025-09-17 19:31:36', 2, 2),
(17, 10, 6, 2, '2025-09-17', 'West Java', 'D2B020125', 4.000, 400, NULL, '2025-08-11 12:14:03', '2025-09-17 19:30:58', 2, 2),
(18, 9, 63, 6, '2025-11-14', 'West Java', '01E020824', 0.010, 2, NULL, '2025-08-11 15:00:39', '2025-11-14 07:31:11', 6, 6),
(19, 11, 61, 6, '2025-11-14', 'West Java', '230711070', 0.050, 5, NULL, '2025-08-11 15:01:31', '2025-11-14 08:04:00', 6, 6),
(20, 6, 11, 8, '2025-11-19', 'West Java', '03B120425', 0.380, 19, NULL, '2025-08-11 16:54:09', '2025-11-19 08:57:10', 8, 8),
(21, 8, 11, 8, '2025-08-21', 'West Java', '01|010125', 0.000, 0, NULL, '2025-08-11 16:54:42', '2025-08-21 09:10:43', 8, 8),
(22, 8, 11, 8, '2025-10-24', 'West Java', '01|020624', 0.000, 0, NULL, '2025-08-11 16:55:36', '2025-10-24 09:29:34', 8, 8),
(23, 11, 36, 8, '2025-08-30', 'West Java', '230711070', 0.000, 0, NULL, '2025-08-11 19:50:08', '2025-08-30 15:53:18', 8, 8),
(24, 8, 36, 8, '2025-08-30', 'West Java', '01|010125', 0.000, 0, NULL, '2025-08-11 19:51:01', '2025-08-30 15:53:07', 8, 8),
(25, 2, 36, 8, '2025-08-30', 'West Java', 'MJ52A1030', 0.000, 0, NULL, '2025-08-11 19:52:37', '2025-08-30 15:55:54', 8, 8),
(26, 2, 36, 8, '2025-08-21', 'West Java', 'MJ52A1021', 0.000, 0, NULL, '2025-08-11 19:53:16', '2025-08-27 09:51:59', 8, 8),
(27, 8, 18, 5, '2025-11-06', 'West Java', '01010125', 0.000, 0, 'Benih belum keluar kembali karena sasaran market mintanya yang smaall poct', '2025-08-11 22:16:16', '2025-11-12 22:50:33', 5, 5),
(28, 5, 18, 5, '2025-11-06', 'West Java', 'Msef1a0024', 0.020, 1, 'Benih untuk pasaran diwilayah tersebut lebih condong ke type lavanta', '2025-08-11 22:18:08', '2026-01-20 11:18:08', 5, 5),
(29, 2, 18, 5, '2025-11-06', 'West Java', '0900504', 35.000, 140, NULL, '2025-08-11 22:19:20', '2026-01-20 11:09:24', 5, 5),
(30, 6, 36, 8, '2025-08-11', 'West Java', '03B120425', 0.000, 0, NULL, '2025-08-12 09:52:36', '2025-08-30 15:52:35', 8, 8),
(31, 2, 58, 6, '2025-11-14', 'West Java', 'NL52A1013', 0.500, 2, NULL, '2025-08-12 10:03:58', '2025-11-14 08:12:42', 6, 6),
(32, 11, 11, 8, '2025-10-24', 'West Java', '230711070', 0.000, 0, NULL, '2025-08-14 15:34:12', '2025-10-24 09:29:43', 8, 8),
(33, 6, 12, 5, '2025-11-08', 'West Java', '03b120425', 0.180, 9, NULL, '2025-08-15 07:24:00', '2025-11-12 22:48:27', 5, 5),
(34, 2, 12, 5, '2025-11-08', 'West Java', 'NJ52A1001', 9.500, 38, 'Update benih dikirim baru 2 dus sekalian penebusan tangki', '2025-08-15 07:25:54', '2025-11-28 10:00:58', 5, 5),
(35, 6, 10, 5, '2025-11-07', 'West Java', '03b180625', 0.300, 15, 'Spreedeng benih terbaru 3 kotak', '2025-08-15 07:27:03', '2025-11-28 10:03:49', 5, 5),
(36, 10, 8, 7, '2025-10-24', 'West Java', '0', 0.200, 20, NULL, '2025-08-15 07:27:33', '2025-10-24 08:37:31', 7, 7),
(37, 4, 10, 5, '2025-11-07', 'West Java', 'Lupa ex 2026', 0.000, 0, 'Stok habis minta order benih jagung Reva kembali', '2025-08-15 07:28:08', '2025-11-12 22:52:02', 5, 5),
(38, 6, 13, 7, '2025-11-19', 'West Java', '03B180625', 1.000, 50, NULL, '2025-08-15 07:29:11', '2025-11-19 07:49:23', 7, 7),
(39, 6, 19, 5, '2025-11-06', 'West Java', '03b180625', 0.060, 3, 'Belum mulai penanaman kembali', '2025-08-15 07:29:27', '2025-11-12 22:51:16', 5, 5),
(40, 2, 38, 8, '2025-11-19', 'West Java', 'NL52A1014', 5.000, 20, NULL, '2025-08-15 07:30:48', '2025-11-19 08:56:37', 8, 8),
(41, 6, 36, 8, '2025-11-19', 'West Java', '03B070325', 0.140, 7, NULL, '2025-08-15 07:31:52', '2025-11-19 08:56:12', 8, 8),
(42, 8, 36, 8, '2025-11-19', 'West Java', '01|020624', 0.015, 3, NULL, '2025-08-15 07:33:27', '2025-11-19 08:55:49', 8, 8),
(43, 6, 17, 7, '2025-10-24', 'West Java', '-', 1.200, 60, NULL, '2025-08-15 07:56:31', '2025-10-24 08:37:52', 7, 7),
(44, 2, 65, 6, '2025-11-14', 'West Java', 'NL52A1014', 2.500, 10, NULL, '2025-08-15 11:44:12', '2025-11-14 07:29:54', 6, 6),
(45, 8, 65, 6, '2025-11-14', 'West Java', '01|020624', 0.000, 0, NULL, '2025-08-15 11:45:33', '2025-11-14 07:28:04', 6, 6),
(46, 6, 65, 6, '2025-11-14', 'West Java', '03B120425', 0.000, 0, NULL, '2025-08-15 11:46:43', '2025-11-14 07:27:55', 6, 6),
(47, 8, 104, 6, '2025-11-14', 'West Java', '01|010125', 0.015, 3, NULL, '2025-08-15 11:47:56', '2025-11-14 08:05:16', 6, 6),
(48, 8, 78, 6, '2025-11-14', 'West Java', '01|010125', 0.000, 0, NULL, '2025-08-15 11:49:08', '2025-11-14 07:37:07', 6, 6),
(49, 5, 68, 6, '2025-11-14', 'West Java', 'MSEF1A0024', 0.200, 10, NULL, '2025-08-15 11:56:57', '2025-11-14 07:32:02', 6, 6),
(50, 6, 98, 6, '2025-11-14', 'West Java', '03B120425', 0.000, 0, NULL, '2025-08-15 11:58:07', '2025-11-14 07:38:38', 6, 6),
(51, 8, 50, 6, '2025-11-14', 'West Java', '01|010125', 0.000, 0, NULL, '2025-08-15 11:59:19', '2025-11-14 07:39:16', 6, 6),
(52, 2, 50, 6, '2025-11-14', 'West Java', 'MJ52A1023', 0.000, 0, NULL, '2025-08-15 12:00:43', '2025-11-14 07:39:07', 6, 6),
(53, 2, 59, 6, '2025-11-14', 'West Java', 'MJ52A1024', 0.000, 0, NULL, '2025-08-15 12:01:56', '2025-11-14 07:40:38', 6, 6),
(54, 6, 59, 6, '2025-11-14', 'West Java', '03B120425', 0.000, 0, NULL, '2025-08-15 12:02:54', '2025-11-14 07:40:27', 6, 6),
(55, 2, 9, 6, '2025-11-14', 'West Java', 'NJ52A1018', 56.250, 225, NULL, '2025-08-15 12:06:49', '2025-11-19 07:14:24', 6, 6),
(56, 8, 9, 6, '2025-11-14', 'West Java', '01|020624', 0.000, 0, NULL, '2025-08-15 12:10:12', '2025-11-14 07:43:03', 6, 6),
(57, 5, 9, 6, '2025-11-14', 'West Java', 'MSEF1A0024', 0.000, 0, NULL, '2025-08-15 12:11:07', '2025-11-14 07:42:45', 6, 6),
(58, 11, 9, 6, '2025-11-14', 'West Java', '230711070', 0.000, 0, NULL, '2025-08-15 12:11:53', '2025-11-14 07:42:01', 6, 6),
(59, 8, 90, 6, '2025-11-14', 'West Java', '01|010125', 0.000, 0, NULL, '2025-08-15 12:12:51', '2025-11-14 07:45:38', 6, 6),
(60, 8, 67, 6, '2025-11-14', 'West Java', '01|020625', 0.040, 8, NULL, '2025-08-15 12:14:53', '2025-11-14 07:49:45', 6, 6),
(61, 6, 67, 6, '2025-11-14', 'West Java', '03B180625', 1.000, 50, NULL, '2025-08-15 12:15:55', '2025-11-14 07:49:25', 6, 6),
(62, 5, 67, 6, '2025-11-14', 'West Java', 'MSEF1A0024', 0.600, 30, NULL, '2025-08-15 12:17:17', '2025-11-14 07:46:54', 6, 6),
(63, 11, 67, 6, '2025-11-14', 'West Java', '230711070', 0.150, 15, NULL, '2025-08-15 12:18:30', '2025-11-14 07:46:37', 6, 6),
(64, 2, 77, 6, '2025-08-14', 'West Java', 'MJ52A1024', 0.000, 0, NULL, '2025-08-15 12:19:58', '2025-08-21 12:57:35', 6, 6),
(65, 5, 77, 6, '2025-08-14', 'West Java', 'MSEF1A0024', 0.000, 0, NULL, '2025-08-15 12:32:39', '2025-08-21 12:56:46', 6, 6),
(66, 8, 66, 6, '2025-11-14', 'West Java', '01|010125', 0.010, 2, NULL, '2025-08-15 12:44:08', '2025-11-14 07:53:20', 6, 6),
(67, 6, 66, 6, '2025-11-14', 'West Java', '03B120425', 0.100, 5, NULL, '2025-08-15 12:45:35', '2025-11-14 07:53:10', 6, 6),
(68, 6, 57, 6, '2025-11-14', 'West Java', '03B180625', 0.400, 20, NULL, '2025-08-15 12:46:36', '2025-11-14 07:54:33', 6, 6),
(69, 11, 80, 6, '2025-11-14', 'West Java', '230711070', 0.000, 0, NULL, '2025-08-15 12:48:24', '2025-11-14 08:07:46', 6, 6),
(70, 8, 62, 6, '2025-11-14', 'West Java', '01|010125', 0.000, 0, NULL, '2025-08-15 12:49:54', '2025-11-14 08:08:42', 6, 6),
(71, 11, 62, 6, '2025-11-14', 'West Java', '230711070', 0.050, 5, NULL, '2025-08-15 12:50:38', '2025-11-14 08:08:33', 6, 6),
(72, 8, 84, 6, '2025-11-14', 'West Java', '01|020624', 0.005, 1, NULL, '2025-08-15 12:51:56', '2025-11-14 08:10:38', 6, 6),
(73, 8, 83, 6, '2025-11-14', 'West Java', '01|010125', 0.025, 5, NULL, '2025-08-15 12:52:39', '2025-11-14 08:14:12', 6, 6),
(74, 2, 15, 7, '2025-11-19', 'West Java', '-', 5.000, 20, 'Exp 18NOV2025', '2025-08-18 09:52:33', '2025-11-19 07:51:14', 7, 7),
(75, 2, 84, 6, '2025-11-14', 'West Java', 'NL52A1014', 7.500, 30, NULL, '2025-08-20 08:23:11', '2025-11-14 08:10:25', 6, 6),
(76, 5, 77, 6, '2025-11-14', 'West Java', 'MSEF1A0024', 0.000, 0, NULL, '2025-08-20 10:56:10', '2025-11-14 07:50:48', 6, 6),
(77, 11, 77, 6, '2025-11-14', 'West Java', '230711070', 0.090, 9, NULL, '2025-08-20 10:56:59', '2025-11-14 07:50:32', 6, 6),
(78, 10, 77, 6, '2025-11-14', 'West Java', '02B050225', 0.000, 0, NULL, '2025-08-20 10:58:23', '2025-11-14 07:50:21', 6, 6),
(79, 2, 77, 6, '2025-11-14', 'West Java', 'NJ52A1001', 0.000, 0, NULL, '2025-08-20 10:59:16', '2025-11-14 07:50:08', 6, 6),
(80, 11, 84, 6, '2025-11-14', 'West Java', '230711070', 0.030, 3, NULL, '2025-08-21 12:49:39', '2025-11-14 08:09:40', 6, 6),
(81, 2, 108, 6, '2025-11-14', 'West Java', 'NL52A1014', 1.250, 5, NULL, '2025-08-21 12:51:55', '2025-11-14 08:12:02', 6, 6),
(82, 2, 104, 6, '2025-11-14', 'West Java', 'NL52A1014', 2.500, 10, NULL, '2025-08-21 12:54:50', '2025-11-14 08:05:26', 6, 6),
(83, 8, 69, 6, '2025-11-14', 'West Java', '01|020624', 0.040, 8, NULL, '2025-08-21 12:56:04', '2025-11-14 07:26:54', 6, 6),
(85, 6, 14, 5, '2025-11-06', 'West Java', '03b180625', 0.080, 4, 'Barang dioper kekios sumbertani 17 pcs', '2025-08-22 14:32:09', '2025-11-12 22:49:26', 5, 5),
(86, 10, 14, 5, '2025-11-06', 'West Java', '0400262', 0.000, 0, 'Benih expayed bulan april 2025 return minta diganti yang baru 11 pcs', '2025-08-22 14:33:23', '2025-11-12 22:49:15', 5, 5),
(87, 9, 61, 6, '2025-11-14', 'West Java', 'MSEB1A0002', 0.000, 0, NULL, '2025-08-22 15:28:24', '2025-11-14 08:03:50', 6, 6),
(88, 6, 9, 6, '2025-11-14', 'West Java', '03B180625', 0.000, 0, NULL, '2025-09-01 09:35:32', '2025-11-14 07:41:46', 6, 6),
(89, 2, 109, 13, '2025-09-01', 'West Java', '123567890', 5.000, 20, 'Bocor', '2025-09-01 12:29:16', NULL, 13, NULL),
(90, 2, 11, 8, '2025-10-24', 'West Java', 'NJ52A1001', 0.000, 0, '27 May 26', '2025-09-02 16:55:48', '2025-10-24 09:29:16', 8, 8),
(91, 9, 9, 6, '2025-11-14', 'West Java', '01E110825', 0.030, 6, NULL, '2025-09-04 12:44:30', '2025-11-19 07:13:25', 6, 6),
(92, 2, 39, 8, '2025-11-19', 'West Java', 'NL52A1014', 20.000, 80, NULL, '2025-09-04 15:48:25', '2025-11-19 08:55:17', 8, 8),
(93, 2, 36, 8, '2025-11-19', 'West Java', 'NL52A1014', 0.750, 3, NULL, '2025-09-04 18:44:14', '2025-11-19 08:54:51', 8, 8),
(94, 2, 41, 8, '2025-11-19', 'West Java', 'NL52A1014', 3.750, 15, NULL, '2025-09-04 18:44:44', '2025-11-19 08:52:40', 8, 8),
(95, 6, 18, 5, '2025-11-06', 'West Java', '03b180625', 1.000, 50, 'Benih baru datang kembali dan langsng spreedeng', '2025-09-04 20:22:46', '2026-01-20 11:01:01', 5, 5),
(96, 10, 18, 5, '2025-11-06', 'West Java', 'Nomor lot lupa dicek', 0.000, 0, 'Benih belum terjual smua karena posisi tanam yang sedang ramai yaitu timun, oyong dan jagung. Untuk paria sebagai opsi', '2025-09-04 20:23:56', '2025-11-12 22:50:06', 5, 5),
(97, 6, 16, 5, '2025-11-06', 'West Java', '03b120425', 0.240, 12, 'Benih baru dikirim kembali 2 kotak', '2025-09-04 20:25:38', '2025-11-28 10:01:55', 5, 5),
(98, 2, 44, 8, '2025-10-24', 'West Java', 'NL52A1014', 2.500, 10, NULL, '2025-09-08 12:20:37', '2025-11-19 08:54:15', 8, 8),
(99, 2, 110, 2, '2025-10-17', 'West Java', 'NJ52A1001', 0.000, 0, NULL, '2025-09-12 11:39:22', '2025-10-17 12:09:30', 9, 2),
(100, 1, 110, 2, '2025-10-17', 'West Java', 'NLL1B1003', 0.000, 0, NULL, '2025-09-12 11:41:14', '2025-10-17 12:09:20', 2, 2),
(101, 6, 110, 2, '2025-10-17', 'West Java', '03B180625', 0.000, 0, NULL, '2025-09-12 11:42:07', '2025-10-17 12:08:50', 2, 2),
(102, 9, 110, 2, '2025-10-17', 'West Java', '01E110825', 0.400, 80, NULL, '2025-09-12 11:42:46', '2025-10-17 12:08:40', 2, 2),
(103, 6, 113, 5, '2025-11-08', 'West Java', '03b180625', 0.000, 0, NULL, '2025-09-17 20:11:34', '2025-11-28 10:12:13', 5, 5),
(104, 2, 57, 6, '2025-11-14', 'West Java', 'NJ52A1001', 2.000, 8, NULL, '2025-09-17 20:13:01', '2025-11-14 07:53:54', 6, 6),
(105, 2, 113, 5, '2025-11-08', 'West Java', 'NJ52A1001', 3.750, 15, NULL, '2025-09-17 20:14:09', '2025-11-28 10:11:45', 5, 5),
(106, 5, 113, 5, '2025-11-08', 'West Java', 'Msef1a0024', 0.000, 0, NULL, '2025-09-17 20:15:18', '2025-11-12 22:54:03', 5, 5),
(107, 2, 70, 6, '2025-11-14', 'West Java', 'NJ52A1001', 0.000, 0, NULL, '2025-09-17 20:18:20', '2025-11-14 08:04:12', 6, 6),
(108, 6, 8, 7, '2025-11-19', 'West Java', '03B180625', 1.300, 65, NULL, '2025-09-18 06:17:45', '2025-11-19 07:46:53', 7, 7),
(109, 2, 13, 7, '2025-11-19', 'West Java', '-', 10.000, 40, NULL, '2025-09-18 06:37:20', '2025-11-19 07:49:09', 7, 7),
(110, 10, 13, 7, '2025-11-19', 'West Java', '-', 0.100, 10, NULL, '2025-09-18 06:38:26', '2025-11-19 07:48:43', 7, 7),
(111, 6, 15, 7, '2025-11-19', 'West Java', '03B180625', 0.200, 10, NULL, '2025-09-18 06:39:49', '2025-11-19 07:50:54', 7, 7),
(112, 10, 15, 7, '2025-11-19', 'West Java', '-', 0.100, 10, NULL, '2025-09-18 06:40:47', '2025-11-19 07:50:38', 7, 7),
(113, 6, 114, 7, '2025-10-24', 'West Java', '-', 0.500, 25, NULL, '2025-09-18 06:42:23', '2025-10-24 08:39:49', 7, 7),
(114, 10, 114, 7, '2025-10-24', 'West Java', '-', 0.230, 23, NULL, '2025-09-18 06:42:46', '2025-10-24 08:40:06', 7, 7),
(115, 11, 78, 6, '2025-11-14', 'West Java', '230711070', 0.000, 0, NULL, '2025-09-26 06:59:46', '2025-11-14 07:36:58', 6, 6),
(116, 11, 90, 6, '2025-11-14', 'West Java', '230711070', 0.100, 10, NULL, '2025-09-26 07:05:33', '2025-11-14 07:45:49', 6, 6),
(117, 2, 11, 8, '2025-11-19', 'West Java', 'NL52A1014', 50.000, 200, NULL, '2025-09-26 08:30:03', '2025-11-19 08:53:30', 8, 8),
(118, 2, 8, 7, '2025-11-19', 'West Java', '-', 3.750, 15, NULL, '2025-10-03 07:23:39', '2025-11-19 07:46:32', 7, 7),
(119, 1, 8, 7, '2025-10-24', 'West Java', '-', 2.000, 8, NULL, '2025-10-03 07:24:09', '2025-10-24 08:36:30', 7, 7),
(120, 2, 106, 6, '2025-11-14', 'West Java', 'NJ52A1001', 1.250, 5, NULL, '2025-10-03 07:38:22', '2025-11-14 07:40:07', 6, 6),
(121, 1, 20, 5, '2025-11-07', 'West Java', 'NLL1B1005', 0.000, 0, 'Stok update terahir yang ada dikios Bu haji tosin pengiriman 6 dus', '2025-10-03 12:21:11', '2025-11-12 22:52:26', 5, 5),
(122, 6, 110, 2, '2025-10-17', 'West Java', '03B010925', 8.000, 400, NULL, '2025-10-03 15:48:45', '2025-10-17 12:08:24', 9, 2),
(123, 7, 110, 2, '2025-10-17', 'West Java', 'NLFB1A0008', 0.000, 0, NULL, '2025-10-03 15:49:25', '2025-10-17 12:05:56', 9, 2),
(124, 2, 116, 11, '2025-10-30', 'West Java', 'NJ52A1008', 25.000, 100, 'Stok Madu59 Cek per-30 OKTOBER', '2025-10-03 16:18:44', '2025-11-07 10:04:16', 11, 11),
(125, 2, 117, 11, '2025-10-24', 'West Java', 'NJ52A1005', 10.000, 40, 'Pengecekan Madu59 10 Box Per-24 OKT', '2025-10-03 16:20:46', '2025-11-07 10:02:14', 11, 11),
(126, 2, 119, 11, '2025-09-03', 'West Java', 'NJ52A1001', 10.000, 40, 'Pengecekan Stok Madu59 dari 10 box (±7)Per-3 SEPTEMBER', '2025-10-03 16:24:03', '2025-11-07 10:02:48', 11, 11),
(127, 2, 115, 11, '2025-11-04', 'West Java', 'NJ52A1017', 20.000, 80, 'Pengecekan stok madu59 Per-04 Nove', '2025-10-03 16:26:04', '2025-11-07 10:01:06', 11, 11),
(128, 2, 118, 11, '2025-10-29', 'West Java', 'NJ52A1006', 50.000, 200, 'Pengecekan stok Madu59 Per-29 Okto', '2025-10-03 16:28:44', '2025-11-07 09:59:58', 11, 11),
(129, 6, 116, 11, '2025-10-30', 'West Java', '038120425', 0.000, 0, 'Belum Stok Kembali', '2025-10-10 08:20:14', '2025-11-07 10:05:11', 11, 11),
(130, 6, 115, 11, '2025-11-03', 'West Java', '03B140425', 0.400, 20, 'Pengecekan Stok terakhir 5 Kotak', '2025-10-10 08:22:11', '2025-11-07 10:06:24', 11, 11),
(131, 8, 115, 11, '2025-10-10', 'West Java', '19002020', 0.250, 50, NULL, '2025-10-10 12:19:39', '2025-11-07 10:07:48', 11, 11),
(132, 8, 116, 11, '2025-10-30', 'West Java', '190C7077', 0.000, 0, 'Belum Stok Kembali', '2025-10-10 12:23:49', '2025-11-07 10:06:51', 11, 11),
(133, 7, 9, 6, '2025-11-14', 'West Java', 'NLFB1A0006', 1.500, 3, NULL, '2025-10-24 07:38:46', '2025-11-14 07:41:16', 6, 6),
(134, 2, 80, 6, '2025-11-14', 'West Java', 'NL52A1014', 0.750, 3, NULL, '2025-10-24 07:47:26', '2025-11-14 08:07:26', 6, 6),
(135, 6, 20, 5, '2025-11-07', 'West Java', '03B010925', 0.000, 0, 'Pengisian 5 kotak lavanta untuk dikenalkan ke petani binaannya', '2025-10-24 08:39:33', '2025-11-28 10:08:44', 5, 5),
(136, 2, 16, 5, '2025-11-06', 'West Java', 'NJ52A1001', 3.750, 15, NULL, '2025-10-24 08:43:25', '2025-11-28 10:02:07', 5, 5),
(137, 2, 40, 8, '2025-11-19', 'West Java', 'NL52A1014', 2.500, 10, NULL, '2025-10-24 09:34:01', '2025-11-19 08:52:59', 8, 8),
(138, 6, 41, 8, '2025-11-19', 'West Java', '03B070325', 0.400, 20, NULL, '2025-10-24 13:39:44', '2025-11-19 08:50:28', 8, 8),
(139, 2, 110, 2, '2025-11-03', 'West Java', 'NL52A1013', 125.000, 500, NULL, '2025-11-03 12:36:02', NULL, 2, NULL),
(140, 2, 110, 2, '2025-11-03', 'West Java', 'NL52A1014', 375.000, 1500, NULL, '2025-11-03 12:36:43', NULL, 2, NULL),
(141, 7, 110, 2, '2025-11-03', 'West Java', 'NLFB1A0020', 40.500, 81, NULL, '2025-11-03 12:38:14', NULL, 2, NULL),
(142, 7, 110, 2, '2025-11-03', 'West Java', 'NLFB1A0019', 34.000, 68, NULL, '2025-11-03 12:38:56', NULL, 2, NULL),
(143, 7, 110, 2, '2025-11-03', 'West Java', 'NLFB1A0009', 4.500, 9, NULL, '2025-11-03 12:39:32', NULL, 2, NULL),
(144, 7, 110, 2, '2025-11-03', 'West Java', 'NLFB1A0012', 1.000, 2, NULL, '2025-11-03 12:40:07', NULL, 2, NULL),
(145, 11, 115, 11, '2025-10-31', 'West Java', 'SHM0345', 0.300, 30, NULL, '2025-11-07 10:08:52', NULL, 11, NULL),
(146, 8, 68, 6, '2025-11-14', 'West Java', '01|010125', 0.010, 2, NULL, '2025-11-12 18:59:40', '2025-11-14 07:31:38', 6, 6),
(147, 7, 18, 5, '2025-11-06', 'West Java', 'Nlfb1a0022', 6.500, 13, NULL, '2025-11-12 22:40:33', '2026-01-20 11:08:49', 5, 5),
(148, 7, 12, 5, '2025-11-08', 'West Java', 'Lupa keluaran pertama wilayah jabar', 1.500, 3, NULL, '2025-11-12 22:41:12', '2025-11-28 09:55:14', 5, 5),
(149, 10, 12, 5, '2025-11-08', 'West Java', 'Nomor lot lupa dicek', 0.170, 17, NULL, '2025-11-12 22:45:58', '2025-11-28 09:55:01', 5, 5),
(150, 5, 12, 5, '2025-11-08', 'West Java', 'Msef1a0024', 0.320, 16, NULL, '2025-11-12 22:47:44', '2025-11-28 09:54:33', 5, 5),
(151, 10, 120, 6, '2025-11-14', 'West Java', '02B020125', 0.500, 50, NULL, '2025-11-14 07:36:29', NULL, 6, NULL),
(152, 10, 57, 6, '2025-11-14', 'West Java', '02B020125', 0.050, 5, NULL, '2025-11-14 07:59:41', NULL, 6, NULL),
(153, 7, 57, 6, '2025-11-14', 'West Java', 'NLFB1A0006', 1.000, 2, NULL, '2025-11-14 08:01:30', NULL, 6, NULL),
(154, 10, 58, 6, '2025-11-14', 'West Java', '02B020125', 0.300, 30, NULL, '2025-11-14 08:13:47', NULL, 6, NULL),
(155, 7, 8, 7, '2025-11-19', 'West Java', '-', 3.500, 7, NULL, '2025-11-19 07:47:45', NULL, 7, NULL),
(156, 7, 13, 7, '2025-11-19', 'West Java', '-', 20.000, 40, NULL, '2025-11-19 07:50:01', NULL, 7, NULL),
(157, 6, 121, 5, '2025-11-28', 'West Java', '03B010925', 0.600, 30, NULL, '2025-11-28 10:44:06', '2025-11-28 10:44:40', 5, 5);

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_00_000001_create_cache_table', 1),
(2, '0001_01_00_000002_create_jobs_table', 1),
(3, '0001_01_00_000003_create_users_table', 1),
(4, '0001_01_00_000004_create_settings_table', 1),
(5, '0001_01_01_000001_create_product_categories_table', 1),
(6, '0001_01_01_000002_create_products_table', 1),
(7, '0001_01_01_000003_create_activity_types', 1),
(8, '0001_01_01_000004_create_customers_table', 1),
(9, '0001_01_02_000001_create_demo_plots_table', 1),
(10, '0001_01_02_000002_create_demo_plot_visits_table', 1),
(11, '0001_01_02_000003_create_activity_targets_table', 1),
(12, '0001_01_02_000004_create_activity_plans_table', 1),
(13, '0001_01_02_000004_create_activity_target_details_table', 1),
(14, '0001_01_02_000005_create_activity_plan_details_table', 1),
(15, '0001_01_02_000006_create_activities_table', 1);

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `category_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `price_1` decimal(10,2) NOT NULL DEFAULT 0.00,
  `uom_1` varchar(255) NOT NULL DEFAULT '',
  `price_2` decimal(10,2) NOT NULL DEFAULT 0.00,
  `uom_2` varchar(255) NOT NULL DEFAULT '',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `notes` text DEFAULT NULL,
  `weight` smallint(5) UNSIGNED DEFAULT NULL,
  `created_datetime` datetime DEFAULT NULL,
  `updated_datetime` datetime DEFAULT NULL,
  `created_by_uid` bigint(20) UNSIGNED DEFAULT NULL,
  `updated_by_uid` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `category_id`, `name`, `price_1`, `uom_1`, `price_2`, `uom_2`, `active`, `notes`, `weight`, `created_datetime`, `updated_datetime`, `created_by_uid`, `updated_by_uid`) VALUES
(1, 9, 'LILAC 22', 306000.00, 'kg', 76500.00, 'pcs', 1, NULL, 250, NULL, '2025-09-18 13:52:40', NULL, 9),
(2, 10, 'MADU 59', 380000.00, 'kg', 95000.00, 'pcs', 1, NULL, 250, NULL, '2025-09-18 13:52:52', NULL, 9),
(3, 10, 'ADV ANARA', 380000.00, 'kg', 95000.00, 'pcs', 1, NULL, 250, NULL, '2025-09-18 13:50:18', NULL, 9),
(4, 10, 'ADV REVA', 380000.00, 'kg', 95000.00, 'pcs', 1, NULL, 250, NULL, '2025-09-18 13:50:39', NULL, 9),
(5, 9, 'GOGOR 22', 2250000.00, 'kg', 45000.00, 'pcs', 1, NULL, 20, NULL, '2025-09-18 13:51:53', NULL, 9),
(6, 9, 'LAVANTA F1', 1850000.00, 'kg', 37000.00, 'pcs', 1, NULL, 20, NULL, '2025-09-18 13:52:30', NULL, 9),
(7, 9, 'HERRA 22', 200000.00, 'kg', 100000.00, 'pcs', 1, NULL, 500, NULL, '2025-09-18 13:52:03', NULL, 9),
(8, 9, 'NONA 23', 34000000.00, 'kg', 170000.00, 'pcs', 1, NULL, 5, NULL, '2025-09-18 13:53:12', NULL, 9),
(9, 9, 'DEBY 23', 21000000.00, 'kg', 105000.00, 'pcs', 1, NULL, 5, NULL, '2025-09-18 13:51:09', NULL, 9),
(10, 9, 'BEIJING 23', 2100000.00, 'kg', 21000.00, 'pcs', 1, NULL, 10, NULL, '2025-09-18 13:51:00', NULL, 9),
(11, 9, 'SHIMA', 5000000.00, 'kg', 50000.00, 'pcs', 1, NULL, 10, NULL, '2025-09-18 13:53:27', NULL, 9),
(12, 2, 'TRIAL L7', 0.00, 'Kg', 0.00, 'pcs', 0, 'TRIAL EXOTIC,MADU,H72', NULL, '2025-07-28 16:03:50', '2025-08-06 18:45:47', 9, 9),
(13, 9, 'AGNI 22 F1', 14500000.00, 'Kg', 145000.00, 'Pcs', 1, NULL, 10, '2025-08-06 18:31:55', '2025-09-18 13:50:50', 9, 9),
(17, 2, 'Trial L5', 1.00, 'Kg', 1.00, 'Pcs', 0, NULL, 1, '2025-09-15 21:55:25', NULL, 9, NULL),
(18, 2, 'HIBRIX 72', 380000.00, 'Kg', 95000.00, 'Pcs', 1, NULL, 250, '2025-12-25 20:11:02', '2025-12-25 20:11:26', 9, 9);

-- --------------------------------------------------------

--
-- Table structure for table `product_categories`
--

CREATE TABLE `product_categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `created_datetime` datetime DEFAULT NULL,
  `updated_datetime` datetime DEFAULT NULL,
  `created_by_uid` bigint(20) UNSIGNED DEFAULT NULL,
  `updated_by_uid` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `product_categories`
--

INSERT INTO `product_categories` (`id`, `name`, `description`, `created_datetime`, `updated_datetime`, `created_by_uid`, `updated_by_uid`) VALUES
(1, 'WAXY CORN', NULL, NULL, NULL, NULL, NULL),
(2, 'SWEET CORN', NULL, NULL, NULL, NULL, NULL),
(3, 'CUCUMBER', NULL, NULL, NULL, NULL, NULL),
(4, 'LONG BEAN', NULL, NULL, NULL, NULL, NULL),
(5, 'TOMATO', NULL, NULL, NULL, NULL, NULL),
(6, 'BITTER GOURD', NULL, NULL, NULL, NULL, NULL),
(7, 'CHILLI - BIRD PAPER', NULL, NULL, NULL, NULL, NULL),
(8, 'CHILLI', '', '2025-08-06 18:30:23', '2025-08-06 18:30:36', 9, 9),
(9, 'Vegetables', 'Sayuran', '2025-09-18 13:43:04', NULL, 9, NULL),
(10, 'Fresh Corn', 'Jagung Manis', '2025-09-18 13:49:50', NULL, 9, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('eEq1AiNj94wbXcxaLuhzPLqVBQJGjNFwUIacWvrP', NULL, '35.171.217.30', 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWEpZVUw3Z1llVlJNSjJqSjhiN001TlhpNVVXZklBaVJtam9YOTBYWSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NDM6Imh0dHBzOi8vd3d3LmFkdmFudGEtcmVwb3J0LnNoaWZ0LWFwcHMubXkuaWQiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX19', 1773052833),
('gDbsAwzg12Egm9X9jviZW7izsfL9noWyWqwgexBI', NULL, '3.139.242.79', 'visionheight.com/scan Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieFhyMHBRc25TNUtzWVd6aHVWM2twV3NzM2FrZWxnc0R4WTVQNHlSNiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Mzk6Imh0dHBzOi8vYWR2YW50YS1yZXBvcnQuc2hpZnQtYXBwcy5teS5pZCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1773060953),
('N93FkJvKaGKKRWk97pcZrr11y6YD5x5MFhIK5z7f', NULL, '35.171.217.30', 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoidlNlMVd1bFp4NWZFMUpnTVk4VHhSd3d6dUhHd01wZkNoVTBpZ0JTaSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NjA6Imh0dHBzOi8vd3d3LmFkdmFudGEtcmVwb3J0LnNoaWZ0LWFwcHMubXkuaWQvYWRtaW4vYXV0aC9sb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1773052834),
('NiZqSxTVMKf0irA8FM8XHhVgQf2mQMT7kKhRE0fK', NULL, '52.2.130.179', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:135.0) Gecko/20100101 Firefox/135.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoib0Y0Z3RxQXJvaTM5Y2Y2MXpINnJpNEdTdkJOVjFON1dKc3BiYmQ2OCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTY6Imh0dHBzOi8vYWR2YW50YS1yZXBvcnQuc2hpZnQtYXBwcy5teS5pZC9hZG1pbi9hdXRoL2xvZ2luIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1773058153),
('RPh6CetQSQ36KZVpyLwDWqlmDmplIBp4FYXKvJ9S', NULL, '134.199.219.196', 'Mozilla/5.0 (X11; Linux x86_64; rv:142.0) Gecko/20100101 Firefox/142.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiV3RPVUIxaEVpT1VGSU9uOFk2N2NQeVVnUjAxa1NFcFdlRWFxY0ZJNCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTY6Imh0dHBzOi8vYWR2YW50YS1yZXBvcnQuc2hpZnQtYXBwcy5teS5pZC9hZG1pbi9hdXRoL2xvZ2luIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1773060958),
('rtbelztScVPkRVpHvjPWuP3FAA9SmVh5Dw4tzKwZ', NULL, '3.139.242.79', 'visionheight.com/scan Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) Chrome/126.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiUGJVZ2EzSXdtbzFqOFhrMDROVU1LdGlHY0M3eE1NNE5mNE9tYlJjQiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTY6Imh0dHBzOi8vYWR2YW50YS1yZXBvcnQuc2hpZnQtYXBwcy5teS5pZC9hZG1pbi9hdXRoL2xvZ2luIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1773060953),
('tJMohMyOlnVTiwHCAhD2qUIukBYaTLC7Akgu9MQc', NULL, '52.2.130.179', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:135.0) Gecko/20100101 Firefox/135.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSktpQnNJd05Ea1NKdTJkeHNzaXNHSURZaGt6QmhkOTh4TkpmM1F5WCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6Mzk6Imh0dHBzOi8vYWR2YW50YS1yZXBvcnQuc2hpZnQtYXBwcy5teS5pZCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1773058152);

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `key` varchar(255) NOT NULL,
  `value` text NOT NULL,
  `created_datetime` datetime DEFAULT NULL,
  `updated_datetime` datetime DEFAULT NULL,
  `created_by_uid` bigint(20) UNSIGNED DEFAULT NULL,
  `updated_by_uid` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`key`, `value`, `created_datetime`, `updated_datetime`, `created_by_uid`, `updated_by_uid`) VALUES
('company_address', '', '2025-07-07 13:53:26', NULL, 9, NULL),
('company_logo_path', 'uploads/logos/logo.png', '2025-07-07 13:53:26', '2025-08-31 19:59:22', 9, 9),
('company_name', 'Advanta Seeds Indonesia', '2025-07-07 13:53:26', '2025-08-31 19:57:38', 9, 9),
('company_phone', '', '2025-07-07 13:53:26', NULL, 9, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `username` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('bs','agronomist','asm','admin') NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 0,
  `work_area` varchar(255) DEFAULT NULL,
  `parent_id` bigint(20) UNSIGNED DEFAULT NULL,
  `last_login_datetime` datetime DEFAULT NULL,
  `last_activity_description` varchar(255) NOT NULL DEFAULT '',
  `last_activity_datetime` datetime DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `name`, `password`, `role`, `active`, `work_area`, `parent_id`, `last_login_datetime`, `last_activity_description`, `last_activity_datetime`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'christienyunianto', 'Christien Yunianto', '$2y$12$8eoxuVNfaQDmhw1lueO5P.c2dheKWAGHwM1OAHx55yI6cK2TYE3Nq', 'asm', 1, '', NULL, '2025-08-06 21:26:35', 'Logout', '2025-08-08 06:36:56', 'cye9L5YCROo96u0GEGTb1SlNQZEa0bn08LjMkHIEMZLncaABNjLkE3yHYzFn', NULL, '2025-08-07 23:36:56'),
(2, 'agusherdianto', 'Agus Herdianto', '$2y$12$v7v1SkNutn8wwPH/oxEuWebAcXX4t6TjCwuPd7hv1tKhWWDYlZwo.', 'agronomist', 1, '', 1, '2026-02-02 07:14:20', 'Login', '2026-02-02 07:14:20', 'bEu5Ev4NySohEV3wu0nvcJWMAPIC8b5ZBuYMEukdnxrXGSPbfj2m5Bz4CJqp', NULL, '2026-02-02 00:14:20'),
(3, 'agusnurjani', 'Agus Nurjani', '$2y$12$8eoxuVNfaQDmhw1lueO5P.c2dheKWAGHwM1OAHx55yI6cK2TYE3Nq', 'agronomist', 1, '', 1, '2025-11-25 10:39:55', 'Login', '2025-11-25 10:39:55', 'l0BN33EI6uzMC4PJW3YInDSq0ydq5xZ8HeZAIdDucJJtzLnrzjKsLhb07Vv2', NULL, '2025-11-25 03:39:55'),
(4, 'chandra', 'Chandra', '$2y$12$8eoxuVNfaQDmhw1lueO5P.c2dheKWAGHwM1OAHx55yI6cK2TYE3Nq', 'agronomist', 1, '', 1, '2025-09-13 11:23:12', 'Logout', '2025-09-13 11:23:41', '5BsBXQOKGrPq0d32LxmOyt6K44XQIHWjpnVnVNjHG15MLmMVgm02vmVoYHGy', NULL, '2025-09-13 04:23:41'),
(5, 'fatkhurokman', 'Fatkhurokman', '$2y$12$8eoxuVNfaQDmhw1lueO5P.c2dheKWAGHwM1OAHx55yI6cK2TYE3Nq', 'bs', 1, 'Cirebon', 2, '2025-09-26 20:34:29', 'Login', '2025-09-26 20:34:29', 'R4kJNjM4lkmkjNpsZtpnDSsw3vpR6ZduF65vsiEusSTfhpz1jMIs0o6fKjyI', NULL, '2025-09-26 13:34:29'),
(6, 'iingmubarok', 'Iing Mubarok', '$2y$12$8eoxuVNfaQDmhw1lueO5P.c2dheKWAGHwM1OAHx55yI6cK2TYE3Nq', 'bs', 1, 'Kuningan - Mjl Hl', 2, '2025-09-30 16:06:12', 'Login', '2025-09-30 16:06:12', 'Ypis5Ak9toMh8kJFhKi0gKTaUuYjlakxD9zHpF2S1nduIT3WnNp3Qu2ABY9w', NULL, '2025-09-30 09:06:12'),
(7, 'rifkifaisal', 'Rifki Faisal', '$2y$12$8eoxuVNfaQDmhw1lueO5P.c2dheKWAGHwM1OAHx55yI6cK2TYE3Nq', 'bs', 1, 'Indramayu - Mjl Ll', 2, '2026-01-14 12:51:03', 'Login', '2026-01-14 12:51:03', 'a9mjOyS2QtlBrkSCTt84rJZ8TZUEzKpuDBDcudVlLMAyYmfcy143fuJkMOBG', NULL, '2026-01-14 05:51:03'),
(8, 'listianto', 'Listianto', '$2y$12$8eoxuVNfaQDmhw1lueO5P.c2dheKWAGHwM1OAHx55yI6cK2TYE3Nq', 'bs', 1, 'Subang - Purwakarta', 2, '2025-10-01 17:11:04', 'Login', '2025-10-01 17:11:04', 'ZZcxal4Yk2tplWPpxJ1j76YITPNz12V5IAz3WLcVnmN3m40IsOhTwB3MoZwY', NULL, '2025-10-01 10:11:04'),
(9, 'admin', 'Admin', '$2y$12$AxkefX1K3U8yjhccMgVsU.SK5fXMLPmNWKlQZVTQAEohffStY2Vce', 'admin', 1, NULL, NULL, '2026-01-02 13:14:56', 'Logout', '2026-01-05 07:13:30', 'whdZ3PifFlUDRt9VCCZcuOng9fdEE3Ep7D8wj8zbqkPNWNOuBGP690J7evIQ', NULL, '2026-01-05 00:13:30'),
(10, 'sysadmin', 'System Administrator', '$2y$12$pI9iMdWmOKhLc/oweCP2g.0mfRkr9jNyJG0kxl.NpVqayt6Q7O9K.', 'admin', 1, NULL, NULL, '2026-03-09 16:04:10', 'Login', '2026-03-09 16:04:10', 'cGNeAuTU66LVhimNOX23MtjwGcWMCqaFULYV51LSxa6U3laYOB3rPQqvHIl1', '2025-07-18 07:04:08', '2026-03-09 09:04:10'),
(11, 'Varyanapriadi', 'Varyan Apriadi', '$2y$12$1bBXuu3hGnVM7757cNxci.5nWXX/YhPxDNvwI9C90I5y1mfPBYru6', 'bs', 1, 'Cianjur', 4, '2025-08-19 17:41:46', 'Login', '2025-08-19 17:41:46', 'UU30slZqICtVXQ13WLpYoiBglOn0Z985Hm0gT5sQgdjLeKQx0Dq9udsFz1dP', '2025-08-08 03:28:30', '2025-08-19 10:41:46'),
(12, 'syarifudin', 'Syarifudin', '$2y$12$xia7rMIJVlUWm1YYy4X4ieYiQ/8MmvXErIxE3Emb9ljdOysm6sY9i', 'bs', 1, 'Cianjur Selatan', 4, NULL, '', NULL, NULL, '2025-08-08 03:29:10', '2025-08-08 03:29:10'),
(13, 'mirda', 'Mirda', '$2y$12$E/vQRQNF6SZwx9.BYu83j.0xcKGGK18RhagBafaVTQUA4FR4ylmvm', 'bs', 1, 'Sukabumi', 4, '2025-09-01 12:46:11', 'Logout', '2025-09-01 12:46:47', '6FVMmRMeySqoAKOUZUTfTEy7I8QtgpZgGysFS8AL6Tc66YFwR7CzNRr2d6yd', '2025-08-08 03:29:36', '2025-09-01 05:46:47'),
(14, 'alvian', 'Alvian', '$2y$12$82T9u3nuYKj5zqN45Gew/eoWk.XlombIYWz.mGizNPURdrm8oSLMW', 'bs', 1, 'Bogor', 4, '2025-09-13 11:19:03', 'Logout', '2025-09-13 11:23:06', 'X3Gdv1r5CfPPMqla9JM1fpaaK9Wcp2SZyBqDaQ1aIhK2RzlUK0WnRFz0O0fC', '2025-08-08 03:30:01', '2025-09-13 04:23:06'),
(15, 'tatasurya', 'Tarya Surya Laksana', '$2y$12$FLuhGVlpPIXr9d7KzqpnLuaW9l7OJJOSJtNdnhXOdC4WDiPDQGzw2', 'bs', 1, 'Bandung Selatan', 3, '2025-11-23 19:17:18', 'Login', '2025-11-23 19:17:18', 'PTJUOFFqlFsSy57cPqINcaugcoMeKTCJBRUxTHLj7bv2azioxsNh6qtFY8Kc', '2025-08-31 02:24:16', '2025-11-23 12:17:18'),
(16, 'Thaharudin', 'Thaharudin Yusuf', '$2y$12$gTDeSKYD4Nca6ASupVMAKukkjhu86SyvMtNGjjs5XcGsJQmPuJyeC', 'bs', 1, 'Garut Atas', 3, '2025-09-11 13:26:19', 'Login', '2025-09-11 13:26:19', '9TeW3KXxqSgAEEFBiL9YC2mBSh7kjHPElKLe7slLIbRZWwQS8mH8OGTxgZy5', '2025-08-31 02:25:20', '2025-09-11 06:26:19'),
(17, 'denyachmad', 'Deny Achmad Fathurahman', '$2y$12$a7JIKjAqguVAfe/MPYlhZuwPDQHBb4dFP1ZI2l/o/fP..1BOgai/G', 'bs', 1, 'Garut Bawah & Tasikmalaya', 3, '2025-10-24 18:58:43', 'Login', '2025-10-24 18:58:43', 'AESz2IwyosATD8iwtDYei2s992JNgUi1b4wi9FMm9tzytP42wQD7iJkGBfV6', '2025-08-31 02:26:07', '2025-10-24 11:58:43'),
(18, 'rizkymauluddin', 'Rizky Mauluddin', '$2y$12$YZUuGQ2B2iTG6qdt6HNveuHINnq.xu5eJZU.gmfz..2gA10mdW4pS', 'bs', 1, 'Sumedang', 3, '2026-01-30 09:55:53', 'Login', '2026-01-30 09:55:53', 'owkbF32ULVvjJj9xidpjWDPqqyoFhYZaGLoOBfYajCkvzjOpllrIix7EsKaz', '2025-08-31 02:27:01', '2026-01-30 02:55:53'),
(19, 'kurnia', 'Kurnia', '$2y$12$zgrjEait8Rld59dHGv06cO/TsSsekqnbm78FJYuO4l2kjhrkGUmku', 'bs', 1, 'Bandung Utara', 3, '2025-09-11 10:35:51', 'Login', '2025-09-11 10:35:51', 'qtjEqiohn3EJDxk027tqarA9eZ6ed7LL6qvNY2WvohAC9hyb5e9YtxgSwvyr', '2025-08-31 02:27:26', '2025-09-11 03:35:51'),
(20, 'didikpermadi', 'Didik Permadi', '$2y$12$93n5v4yUtQviumEnEQJ6XOWPu3FjxjczM3SZsQDV9My5fUVCUQSXu', 'asm', 1, 'Nasional', NULL, NULL, '', NULL, NULL, '2025-09-15 14:34:05', '2025-09-15 14:34:05'),
(21, 'andrypurwono', 'Andry Purwono', '$2y$12$8GbJswgshrrV01.OYUJ7eethUS0wDPEMxtV9RqgwyoeqOuMXlOdv6', 'bs', 1, 'Jabar', 20, '2025-09-15 21:45:20', 'Login', '2025-09-15 21:45:20', '7UK130XH9kkIdJ75j7mHmQlW3DkyrAt2sH4CTHQs1aMZkQCT9eY3aBmDcUYu', '2025-09-15 14:34:58', '2025-09-15 14:47:30');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `activities`
--
ALTER TABLE `activities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `activities_user_id_foreign` (`user_id`),
  ADD KEY `activities_type_id_foreign` (`type_id`),
  ADD KEY `activities_product_id_foreign` (`product_id`),
  ADD KEY `activities_responded_by_id_foreign` (`responded_by_id`),
  ADD KEY `activities_created_by_uid_foreign` (`created_by_uid`),
  ADD KEY `activities_updated_by_uid_foreign` (`updated_by_uid`);

--
-- Indexes for table `activity_plans`
--
ALTER TABLE `activity_plans`
  ADD PRIMARY KEY (`id`),
  ADD KEY `activity_plans_user_id_foreign` (`user_id`),
  ADD KEY `activity_plans_responded_by_id_foreign` (`responded_by_id`),
  ADD KEY `activity_plans_created_by_uid_foreign` (`created_by_uid`),
  ADD KEY `activity_plans_updated_by_uid_foreign` (`updated_by_uid`);

--
-- Indexes for table `activity_plan_details`
--
ALTER TABLE `activity_plan_details`
  ADD PRIMARY KEY (`id`),
  ADD KEY `activity_plan_details_parent_id_foreign` (`parent_id`),
  ADD KEY `activity_plan_details_type_id_foreign` (`type_id`),
  ADD KEY `activity_plan_details_product_id_foreign` (`product_id`),
  ADD KEY `activity_plan_details_created_by_uid_foreign` (`created_by_uid`),
  ADD KEY `activity_plan_details_updated_by_uid_foreign` (`updated_by_uid`);

--
-- Indexes for table `activity_targets`
--
ALTER TABLE `activity_targets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `activity_targets_user_id_year_quarter_unique` (`user_id`,`year`,`quarter`),
  ADD KEY `activity_targets_created_by_uid_foreign` (`created_by_uid`),
  ADD KEY `activity_targets_updated_by_uid_foreign` (`updated_by_uid`);

--
-- Indexes for table `activity_target_details`
--
ALTER TABLE `activity_target_details`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `activity_types`
--
ALTER TABLE `activity_types`
  ADD PRIMARY KEY (`id`),
  ADD KEY `activity_types_created_by_uid_foreign` (`created_by_uid`),
  ADD KEY `activity_types_updated_by_uid_foreign` (`updated_by_uid`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `customers_assigned_user_id_foreign` (`assigned_user_id`),
  ADD KEY `customers_created_by_uid_foreign` (`created_by_uid`),
  ADD KEY `customers_updated_by_uid_foreign` (`updated_by_uid`),
  ADD KEY `customers_phone_index` (`phone`);

--
-- Indexes for table `demo_plots`
--
ALTER TABLE `demo_plots`
  ADD PRIMARY KEY (`id`),
  ADD KEY `demo_plots_user_id_foreign` (`user_id`),
  ADD KEY `demo_plots_product_id_foreign` (`product_id`),
  ADD KEY `demo_plots_created_by_uid_foreign` (`created_by_uid`),
  ADD KEY `demo_plots_updated_by_uid_foreign` (`updated_by_uid`);

--
-- Indexes for table `demo_plot_visits`
--
ALTER TABLE `demo_plot_visits`
  ADD PRIMARY KEY (`id`),
  ADD KEY `demo_plot_visits_user_id_foreign` (`user_id`),
  ADD KEY `demo_plot_visits_demo_plot_id_foreign` (`demo_plot_id`),
  ADD KEY `demo_plot_visits_created_by_uid_foreign` (`created_by_uid`),
  ADD KEY `demo_plot_visits_updated_by_uid_foreign` (`updated_by_uid`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `inventory_logs`
--
ALTER TABLE `inventory_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `inventory_logs_product_id_foreign` (`product_id`),
  ADD KEY `inventory_logs_customer_id_foreign` (`customer_id`),
  ADD KEY `inventory_logs_user_id_foreign` (`user_id`),
  ADD KEY `inventory_logs_created_by_uid_foreign` (`created_by_uid`),
  ADD KEY `inventory_logs_updated_by_uid_foreign` (`updated_by_uid`),
  ADD KEY `idx_customer_product_checkdate` (`customer_id`,`product_id`,`check_date`,`id`),
  ADD KEY `inventory_logs_user_id_index` (`user_id`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `products_created_by_uid_foreign` (`created_by_uid`),
  ADD KEY `products_updated_by_uid_foreign` (`updated_by_uid`);

--
-- Indexes for table `product_categories`
--
ALTER TABLE `product_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `product_categories_name_unique` (`name`),
  ADD KEY `product_categories_created_by_uid_foreign` (`created_by_uid`),
  ADD KEY `product_categories_updated_by_uid_foreign` (`updated_by_uid`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`key`),
  ADD KEY `settings_created_by_uid_foreign` (`created_by_uid`),
  ADD KEY `settings_updated_by_uid_foreign` (`updated_by_uid`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `users_parent_id_foreign` (`parent_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `activities`
--
ALTER TABLE `activities`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=401;

--
-- AUTO_INCREMENT for table `activity_plans`
--
ALTER TABLE `activity_plans`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=59;

--
-- AUTO_INCREMENT for table `activity_plan_details`
--
ALTER TABLE `activity_plan_details`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=300;

--
-- AUTO_INCREMENT for table `activity_targets`
--
ALTER TABLE `activity_targets`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `activity_target_details`
--
ALTER TABLE `activity_target_details`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=174;

--
-- AUTO_INCREMENT for table `activity_types`
--
ALTER TABLE `activity_types`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=122;

--
-- AUTO_INCREMENT for table `demo_plots`
--
ALTER TABLE `demo_plots`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=381;

--
-- AUTO_INCREMENT for table `demo_plot_visits`
--
ALTER TABLE `demo_plot_visits`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=815;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventory_logs`
--
ALTER TABLE `inventory_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=158;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `product_categories`
--
ALTER TABLE `product_categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `activities`
--
ALTER TABLE `activities`
  ADD CONSTRAINT `activities_created_by_uid_foreign` FOREIGN KEY (`created_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `activities_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  ADD CONSTRAINT `activities_responded_by_id_foreign` FOREIGN KEY (`responded_by_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `activities_type_id_foreign` FOREIGN KEY (`type_id`) REFERENCES `activity_types` (`id`),
  ADD CONSTRAINT `activities_updated_by_uid_foreign` FOREIGN KEY (`updated_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `activities_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `activity_plans`
--
ALTER TABLE `activity_plans`
  ADD CONSTRAINT `activity_plans_created_by_uid_foreign` FOREIGN KEY (`created_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `activity_plans_responded_by_id_foreign` FOREIGN KEY (`responded_by_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `activity_plans_updated_by_uid_foreign` FOREIGN KEY (`updated_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `activity_plans_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `activity_plan_details`
--
ALTER TABLE `activity_plan_details`
  ADD CONSTRAINT `activity_plan_details_created_by_uid_foreign` FOREIGN KEY (`created_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `activity_plan_details_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `activity_plans` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `activity_plan_details_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  ADD CONSTRAINT `activity_plan_details_type_id_foreign` FOREIGN KEY (`type_id`) REFERENCES `activity_types` (`id`),
  ADD CONSTRAINT `activity_plan_details_updated_by_uid_foreign` FOREIGN KEY (`updated_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `activity_targets`
--
ALTER TABLE `activity_targets`
  ADD CONSTRAINT `activity_targets_created_by_uid_foreign` FOREIGN KEY (`created_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `activity_targets_updated_by_uid_foreign` FOREIGN KEY (`updated_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `activity_types`
--
ALTER TABLE `activity_types`
  ADD CONSTRAINT `activity_types_created_by_uid_foreign` FOREIGN KEY (`created_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `activity_types_updated_by_uid_foreign` FOREIGN KEY (`updated_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `customers`
--
ALTER TABLE `customers`
  ADD CONSTRAINT `customers_assigned_user_id_foreign` FOREIGN KEY (`assigned_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `customers_created_by_uid_foreign` FOREIGN KEY (`created_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `customers_updated_by_uid_foreign` FOREIGN KEY (`updated_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `demo_plots`
--
ALTER TABLE `demo_plots`
  ADD CONSTRAINT `demo_plots_created_by_uid_foreign` FOREIGN KEY (`created_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `demo_plots_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  ADD CONSTRAINT `demo_plots_updated_by_uid_foreign` FOREIGN KEY (`updated_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `demo_plots_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `demo_plot_visits`
--
ALTER TABLE `demo_plot_visits`
  ADD CONSTRAINT `demo_plot_visits_created_by_uid_foreign` FOREIGN KEY (`created_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `demo_plot_visits_demo_plot_id_foreign` FOREIGN KEY (`demo_plot_id`) REFERENCES `demo_plots` (`id`),
  ADD CONSTRAINT `demo_plot_visits_updated_by_uid_foreign` FOREIGN KEY (`updated_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `demo_plot_visits_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `inventory_logs`
--
ALTER TABLE `inventory_logs`
  ADD CONSTRAINT `inventory_logs_created_by_uid_foreign` FOREIGN KEY (`created_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `inventory_logs_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `inventory_logs_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `inventory_logs_updated_by_uid_foreign` FOREIGN KEY (`updated_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `inventory_logs_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_created_by_uid_foreign` FOREIGN KEY (`created_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `products_updated_by_uid_foreign` FOREIGN KEY (`updated_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `product_categories`
--
ALTER TABLE `product_categories`
  ADD CONSTRAINT `product_categories_created_by_uid_foreign` FOREIGN KEY (`created_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `product_categories_updated_by_uid_foreign` FOREIGN KEY (`updated_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `settings`
--
ALTER TABLE `settings`
  ADD CONSTRAINT `settings_created_by_uid_foreign` FOREIGN KEY (`created_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `settings_updated_by_uid_foreign` FOREIGN KEY (`updated_by_uid`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
