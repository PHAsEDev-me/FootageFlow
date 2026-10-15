import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as fm;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';


final ValueNotifier<String> footageFlowLanguage = ValueNotifier<String>('en');
const Map<String, String> _faStrings = {
  'Home':'خانه','Projects':'پروژه‌ها','Inbox':'صندوق ورودی','Library':'کتابخانه','Downloads':'دانلودها','Share':'اشتراک‌گذاری','Settings':'تنظیمات',
  'Replay tutorial':'نمایش دوباره آموزش','Skip tour':'رد کردن آموزش','Back':'قبلی','Next':'بعدی','Get started':'شروع کنید',
  'Welcome to FootageFlow':'به FootageFlow خوش آمدید','Create your first project':'اولین پروژه خود را بسازید',
  'Download footage':'دانلود فوتیج','Build your library':'کتابخانه خود را بسازید','Configure your tools':'ابزارها را تنظیم کنید','Ready to create!':'آماده شروع هستید!',
  'Your creative workspace for collecting, organizing and sharing footage. Take a quick tour, or skip and explore.':'فضای کاری شما برای جمع‌آوری، مدیریت و اشتراک‌گذاری فوتیج‌ها. آموزش کوتاه را ببینید یا مستقیماً شروع کنید.',
  'Open Projects to create a workspace. Choose a name and location; FootageFlow organizes your footage into folders.':'از بخش پروژه‌ها یک فضای کاری بسازید. نام و مسیر را انتخاب کنید تا فوتیج‌ها مرتب بمانند.',
  'Open Inbox, paste a video link, then choose video, audio or a time range. Downloads can be managed in the queue.':'صندوق ورودی را باز کنید، لینک ویدیو را وارد کنید و حالت ویدیو، صدا یا برش زمانی را انتخاب کنید.',
  'Search your footage, group it into collections, and drag files directly into your editing workflow.':'فوتیج‌ها را جستجو و دسته‌بندی کنید و فایل‌ها را مستقیم به نرم‌افزار تدوین بکشید.',
  'In Settings, choose yt-dlp and FFmpeg executables if needed. You can configure proxy and YouTube authentication here too.':'در تنظیمات، مسیر yt-dlp و FFmpeg و همچنین پروکسی و احراز هویت YouTube را مشخص کنید.',
  'You can revisit this guide any time from Settings. Enjoy your workflow!':'هر زمان خواستید می‌توانید از تنظیمات این آموزش را دوباره ببینید.',
  'New Project':'پروژه جدید','Create Project':'ساخت پروژه','Create project':'ساخت پروژه','Open Project':'باز کردن پروژه',
  'Choose a folder...':'انتخاب پوشه...','Choose footage library folder':'انتخاب پوشه فوتیج',
  'Cancel':'انصراف','Create':'ساخت','Delete':'حذف','Remove':'برداشتن','Rename':'تغییر نام','Edit':'ویرایش','Save':'ذخیره','Close':'بستن','Open':'باز کردن',
  'Copy':'کپی','Move':'انتقال','Import':'وارد کردن','Export':'خروجی گرفتن','Search':'جستجو','Clear':'پاک کردن','Browse':'انتخاب فایل',
  'Select all':'انتخاب همه','Select All':'انتخاب همه','Retry':'تلاش مجدد','Pause':'مکث','Resume':'ادامه','Stop':'توقف',
  'Replace':'جایگزینی','Keep both':'نگهداری هر دو','Keep Both':'نگهداری هر دو',
  'Video':'ویدیو','Audio':'صدا','Image':'تصویر','Full video':'ویدیوی کامل','Full audio':'صدای کامل','Clip':'برش',
  'Download':'دانلود','Downloading':'در حال دانلود','Completed':'تکمیل‌شده','Failed':'ناموفق','Pending':'در انتظار',
  'Name':'نام','Date':'تاریخ','Size':'حجم','Type':'نوع','Quality':'کیفیت','Status':'وضعیت','Folder':'پوشه','Path':'مسیر',
  'Select':'انتخاب','Selected':'انتخاب‌شده','All':'همه','None':'هیچ‌کدام','No projects yet':'هنوز پروژه‌ای وجود ندارد',
  'Configure external tools used by FootageFlow.':'ابزارهای خارجی مورد استفاده FootageFlow را تنظیم کنید.',
  'FFmpeg is not downloaded by the app. Choose an existing ffmpeg.exe on this PC.':'برنامه FFmpeg را دانلود نمی‌کند. فایل ffmpeg.exe موجود در رایانه را انتخاب کنید.',
  'yt-dlp is not downloaded by the app. Choose an existing yt-dlp.exe on this PC.':'برنامه yt-dlp را دانلود نمی‌کند. فایل yt-dlp.exe موجود در رایانه را انتخاب کنید.',
  'Choose ffmpeg.exe':'انتخاب ffmpeg.exe','Choose yt-dlp.exe':'انتخاب yt-dlp.exe','Change path':'تغییر مسیر',
  'Download FFmpeg':'دریافت FFmpeg','Download yt-dlp':'دریافت yt-dlp',
  'YouTube Authentication':'احراز هویت YouTube','Off':'خاموش','Browser cookies':'کوکی مرورگر','Browser':'مرورگر',
  'Save YouTube authentication':'ذخیره احراز هویت YouTube','Network / Proxy':'شبکه / پروکسی',
  'Default download folder':'پوشه پیش‌فرض دانلود','Choose default download folder':'انتخاب پوشه پیش‌فرض دانلود',
  'System / Auto':'سیستم / خودکار','Custom':'سفارشی','System':'سیستم','Auto':'خودکار',
  'Save settings':'ذخیره تنظیمات','Save proxy':'ذخیره پروکسی','Reset':'بازنشانی',
  'Coming in the next step':'در مرحله بعد اضافه می‌شود',
  'Everything you collect stays organized by edit.':'همه فوتیج‌های شما برای هر پروژه مرتب می‌مانند.',
  'Local import':'فایل محلی','Website':'وب‌سایت',
  'No files found':'فایلی پیدا نشد','No downloads yet':'هنوز دانلودی ندارید',
  'Add files':'افزودن فایل‌ها','Add Files':'افزودن فایل‌ها','Open folder':'باز کردن پوشه',
  'Project name':'نام پروژه','Description':'توضیحات','Details':'جزئیات','Actions':'عملیات',
  'Start':'شروع','End':'پایان','Duration':'مدت','Source':'منبع','Destination':'مقصد',
  'Done':'انجام شد','Error':'خطا','Warning':'هشدار','Yes':'بله','No':'خیر',
  'Select all visible': 'انتخاب همه موارد نمایان',
  'Clear visible': 'لغو انتخاب موارد نمایان',
  'Import footage': 'وارد کردن فوتیج',
  'All quality': 'همه کیفیت\u200cها',
  'Import shared pack': 'وارد کردن بسته اشتراکی',
  'Importing...': 'در حال وارد کردن...',
  'Share project': 'اشتراک\u200cگذاری پروژه',
  'Share selected': 'اشتراک\u200cگذاری انتخاب\u200cشده\u200cها',
  'Share selected items': 'اشتراک\u200cگذاری موارد انتخاب\u200cشده',
  'Save network settings': 'ذخیره تنظیمات شبکه',
  'Uses Windows/environment proxy automatically.': 'از پروکسی ویندوز یا متغیرهای محیطی به\u200cصورت خودکار استفاده می\u200cشود.',
  'Ignores proxy environment for downloads.': 'برای دانلودها پروکسی محیط سیستم نادیده گرفته می\u200cشود.',
  'Custom proxy is passed to yt-dlp and the FFmpeg process.': 'پروکسی سفارشی به yt-dlp و FFmpeg ارسال می\u200cشود.',
  'Paste a public media link to begin.': 'برای شروع، لینک عمومی رسانه را وارد کنید.',
  'Create a project first.': 'ابتدا یک پروژه بسازید.',
  'Create new project': 'ساخت پروژه جدید',
  'New project': 'پروژه جدید',
  'Selecting': 'در حال انتخاب',
  'Select items': 'انتخاب موارد',
  'All formats': 'همه فرمت\u200cها',
  'All types': 'همه نوع\u200cها',
  'All sources': 'همه منابع',
  'All projects': 'همه پروژه\u200cها',
  'All collections': 'همه مجموعه\u200cها',
  'All statuses': 'همه وضعیت\u200cها',
  'Shareable': 'قابل اشتراک',
  'shareable': 'قابل اشتراک',
  'No footage selected': 'فوتیجی انتخاب نشده',
  'No footage selected.': 'هیچ فوتیجی انتخاب نشده است.',
  'Importing footage...': 'در حال وارد کردن فوتیج...',
  'Add footage': 'افزودن فوتیج',
  'Create New Project': 'ساخت پروژه جدید',
  'Create a new project': 'ساخت پروژه جدید',
  'No active downloads': 'دانلود فعالی وجود ندارد',
  'Download queue': 'صف دانلود',
  'Choose quality': 'انتخاب کیفیت',
  'Paste URL': 'لینک را وارد کنید',
  'Analyze': 'بررسی لینک',
  'Choose source': 'انتخاب منبع',
  'Select folder': 'انتخاب پوشه',
  'Settings saved': 'تنظیمات ذخیره شد',
  'Saved': 'ذخیره شد',
  'Proxy': 'پروکسی',
  'Proxy URL': 'آدرس پروکسی',
  'Download settings': 'تنظیمات دانلود',
  'Network settings': 'تنظیمات شبکه',
  'Source link': 'لینک منبع',
  'Paste a link': 'لینک را وارد کنید',
  'items': 'مورد',
  'item': 'مورد',
  'B': 'بایت',
  'Language':'زبان','English':'انگلیسی','Persian':'فارسی',
  'Create first project': 'ساخت اولین پروژه',
  'Recent projects': 'پروژه‌های اخیر',
  'Your footage workspace': 'فضای کاری فوتیج شما',
  'Good evening': 'عصر بخیر',
  'Good morning': 'صبح بخیر',
  'Good afternoon': 'بعدازظهر بخیر',
  'Save location': 'محل ذخیره',
  'Create another project first.': 'ابتدا یک پروژه دیگر بسازید.',
  'No projects found': 'پروژه‌ای پیدا نشد',
  'Create a project and start collecting footage.': 'یک پروژه بسازید و جمع‌آوری فوتیج را شروع کنید.',
  'Search projects by name or path...': 'جستجوی پروژه با نام یا مسیر...',
  'Search this project...': 'جستجو در این پروژه...',
  'Search footage...': 'جستجوی فوتیج...',
  'Jets, Smoke, Fight...': 'جت، دود، مبارزه...',
  'e.g. Madara Edit': 'مثلاً ادیت مادارا',
  'Choose whether to only remove the projects from Footage Collector, or also permanently delete their folders and files from Windows.': 'انتخاب کنید فقط پروژه‌ها از برنامه حذف شوند یا پوشه‌ها و فایل‌هایشان نیز برای همیشه از ویندوز پاک شوند.',
  'Remove from app': 'حذف از برنامه',
  'Delete folders too': 'حذف پوشه‌ها نیز',
  'Delete files too': 'حذف فایل‌ها نیز',
  'Remove only from Footage Collector, or also delete the actual files from disk?': 'فقط از برنامه حذف شود یا فایل‌های اصلی نیز از دیسک پاک شوند؟',
  'No collection': 'بدون مجموعه',
  'No footage matches these filters.': 'هیچ فوتیجی با این فیلترها پیدا نشد.',
  'No shareable footage yet.': 'هنوز فوتیج قابل اشتراکی وجود ندارد.',
  'Nothing shareable. Local imports do not contain a source link.': 'موردی برای اشتراک وجود ندارد؛ فایل‌های محلی لینک منبع ندارند.',
  'Nothing shareable. Selected local imports do not contain a source link.': 'موردی برای اشتراک وجود ندارد؛ فایل‌های محلی انتخاب‌شده لینک منبع ندارند.',
  'New collection': 'مجموعه جدید',
  'Rename collection': 'تغییر نام مجموعه',
  'Delete collection': 'حذف مجموعه',
  'Delete collection?': 'مجموعه حذف شود؟',
  'Destination collection': 'مجموعه مقصد',
  'Destination collection (optional)': 'مجموعه مقصد (اختیاری)',
  'Unsorted': 'دسته‌بندی‌نشده',
  'File already exists': 'فایل از قبل وجود دارد',
  'Skip': 'رد کردن',
  'Favorites': 'علاقه‌مندی‌ها',
  'Select project': 'انتخاب پروژه',
  'Choose project': 'انتخاب پروژه',
  'Move to project': 'انتقال به پروژه',
  'Copy to project': 'کپی به پروژه',
  'Move to collection': 'انتقال به مجموعه',
  'Remove from Library': 'حذف از کتابخانه',
  'Delete file from disk': 'حذف فایل از دیسک',
  'Delete file?': 'فایل حذف شود؟',
  'Show in folder': 'نمایش در پوشه',
  'Open file': 'باز کردن فایل',
  'Open source': 'باز کردن منبع',
  'Copy link': 'کپی لینک',
  'Collection': 'مجموعه',
  'Project': 'پروژه',
  'Footages': 'فوتیج‌ها',
  'Library size': 'حجم کتابخانه',
  'Universal Downloader': 'دانلودر چندمنظوره',
  'YouTube, Instagram, TikTok, Pinterest and many other supported public links.': 'پشتیبانی از لینک‌های عمومی YouTube، Instagram، TikTok، Pinterest و بسیاری سایت‌های دیگر.',
  'Available formats': 'فرمت‌های موجود',
  'Save destination': 'محل ذخیره',
  'Windows Downloads (default)': 'دانلودهای ویندوز (پیش‌فرض)',
  'Windows Downloads': 'دانلودهای ویندوز',
  'Download mode': 'حالت دانلود',
  'Full': 'کامل',
  'Video • Audio • Image': 'ویدیو • صدا • تصویر',
  'Video-only format: FFmpeg is required to merge the best audio. Configure ffmpeg.exe in Settings.': 'برای ترکیب ویدیو با بهترین صدا، FFmpeg لازم است. مسیر ffmpeg.exe را در تنظیمات مشخص کنید.',
  'Add to downloads': 'افزودن به دانلودها',
  'Paste a link and press Analyze': 'لینک را وارد کنید و دکمه بررسی لینک را بزنید.',
  'Paste media URL...': 'لینک ویدیو را وارد کنید...',
  'yt-dlp and FFmpeg are configured in Settings.': 'ابزارهای yt-dlp و FFmpeg از بخش تنظیمات پیکربندی می‌شوند.',
  'Download log': 'گزارش دانلود',
  'Download again': 'دانلود دوباره',
  'Continue': 'ادامه',
  'Remove from list': 'حذف از فهرست',
  'View log': 'نمایش گزارش',
  'Copy log': 'کپی گزارش',
  'Output': 'خروجی',
  'Do not assign to a project': 'بدون اختصاص به پروژه',
  'Everything you collected, searchable and organized.': 'تمام فوتیج‌های جمع‌آوری‌شده، مرتب و قابل جستجو.',
  'Where should downloads go?': 'دانلودها کجا ذخیره شوند؟',
  'Share entire project': 'اشتراک‌گذاری کل پروژه',
  'Send source links as a tiny .fcshare pack — never the local media files.': 'فقط لینک منابع در یک بسته کوچک .fcshare ارسال می‌شود، نه فایل‌های رسانه‌ای محلی.',
  'Only footage with an original source URL can be shared. Local imports and local PC paths are excluded.': 'فقط فوتیج‌های دارای لینک منبع اصلی قابل اشتراک‌اند؛ فایل‌ها و مسیرهای محلی ارسال نمی‌شوند.',
  'Import shared downloads?': 'دانلودهای اشتراکی وارد شوند؟',
  'This is not a valid Footage Collector share pack.': 'این بسته اشتراک FootageFlow معتبر نیست.',
  'This share pack is empty.': 'بسته اشتراک خالی است.',
  'FFmpeg detected': 'FFmpeg شناسایی شد',
  'FFmpeg not found': 'FFmpeg پیدا نشد',
  'yt-dlp detected': 'yt-dlp شناسایی شد',
  'yt-dlp not found': 'yt-dlp پیدا نشد',
  'Please choose ffmpeg.exe.': 'لطفاً فایل ffmpeg.exe را انتخاب کنید.',
  'This file is not a valid FFmpeg executable.': 'این فایل اجرایی FFmpeg معتبر نیست.',
  'Please choose yt-dlp.exe.': 'لطفاً فایل yt-dlp.exe را انتخاب کنید.',
  'This file is not a valid yt-dlp executable.': 'این فایل اجرایی yt-dlp معتبر نیست.',
  'Could not open the download page.': 'صفحه دانلود باز نشد.',
  'Use your own local browser session when YouTube asks to confirm you are not a bot. FootageFlow never uploads or bundles your cookies.': 'اگر YouTube درخواست تأیید هویت کرد، از نشست مرورگر خود استفاده کنید. FootageFlow کوکی‌های شما را آپلود یا همراه برنامه بسته‌بندی نمی‌کند.',
  'cookies.txt': 'cookies.txt',
  'You must be signed in to YouTube in the selected browser.': 'باید در مرورگر انتخاب‌شده وارد حساب YouTube شده باشید.',
  'Choose cookies.txt': 'انتخاب cookies.txt',
  'Choose a valid cookies.txt file first.': 'ابتدا یک فایل cookies.txt معتبر انتخاب کنید.',
  'YouTube authentication settings saved.': 'تنظیمات احراز هویت YouTube ذخیره شد.',
  'Security: cookies stay on this PC. Never commit cookies.txt to GitHub or share it with anyone.': 'امنیت: کوکی‌ها فقط در این رایانه می‌مانند. فایل cookies.txt را در GitHub قرار ندهید و با کسی به اشتراک نگذارید.',
  'Use the same proxy for yt-dlp and FFmpeg clip streams. Mixed ports such as 127.0.0.1:10808 are supported.': 'برای yt-dlp و استریم برش‌های FFmpeg از یک پروکسی استفاده کنید. آدرس‌هایی مانند 127.0.0.1:10808 پشتیبانی می‌شوند.',
  'IP / Host': 'آدرس IP / میزبان',
  'Port': 'پورت',
  'Network settings saved.': 'تنظیمات شبکه ذخیره شد.',
  'Enter an IP address or host, for example 127.0.0.1': 'یک آدرس IP یا میزبان وارد کنید؛ مانند 127.0.0.1',
  'Enter a valid port between 1 and 65535.': 'یک پورت معتبر بین ۱ تا ۶۵۵۳۵ وارد کنید.',
  'Used whenever you download without selecting a project.': 'زمانی استفاده می‌شود که بدون انتخاب پروژه دانلود می‌کنید.',
  'Use Windows default': 'استفاده از پیش‌فرض ویندوز',
  'About FootageFlow': 'درباره FootageFlow',
  'Created by PHAsE': 'ساخته‌شده توسط PHAsE',
  'Special Thanks': 'تشکر ویژه',
  'For support and contribution to the project.': 'برای پشتیبانی و همکاری در پروژه.',
};
String ffTranslate(String value) {
  if (footageFlowLanguage.value != 'fa') return value;
  final exact = _faStrings[value];
  if (exact != null) return exact;
  if (value.startsWith('Delete ') && value.endsWith(' selected items?')) return 'موارد انتخاب‌شده حذف شوند؟';
  if (value.startsWith('Delete ') && value.contains(' project')) return 'پروژه‌های انتخاب‌شده حذف شوند؟';
  if (value.startsWith('Move ') && value.contains(' selected item')) return 'انتقال موارد انتخاب‌شده';
  if (value.endsWith(' selected')) return '${value.substring(0, value.length - 9)} انتخاب‌شده';
  if (value.startsWith('Drop files into ')) return 'فایل‌ها را اینجا رها کنید: ${value.substring(16)}';
  return value;
}
class Text extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool? softWrap;
  final TextDirection? textDirection;
  final TextScaler? textScaler;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  const Text(this.data, {super.key, this.style, this.textAlign, this.overflow, this.maxLines, this.softWrap, this.textDirection, this.textScaler, this.semanticsLabel, this.textWidthBasis});
  @override Widget build(BuildContext context) => ValueListenableBuilder<String>(
    valueListenable: footageFlowLanguage,
    builder: (context, lang, _) => fm.Text(
      ffTranslate(data), style: style, textAlign: textAlign, overflow: overflow,
      maxLines: maxLines, softWrap: softWrap, textDirection: textDirection,
      textScaler: textScaler, semanticsLabel: semanticsLabel, textWidthBasis: textWidthBasis,
    ),
  );
}

class _NativeFileDrag {
  static const MethodChannel _singleChannel = MethodChannel('footage_collector/native_file_drag');
  static const MethodChannel _multiChannel = MethodChannel('footage_collector/native_multi_file_drag');
  static Future<void> start(List<String> paths) async {
    final clean = paths.where((p) => p.trim().isNotEmpty && File(p).existsSync()).toSet().toList();
    if (!Platform.isWindows || clean.isEmpty) return;
    try {
      if (clean.length == 1) {
        await _singleChannel.invokeMethod('startFileDrag', {'path': clean.first});
      } else {
        await _multiChannel.invokeMethod('startFilesDrag', {'paths': clean});
      }
    } catch (_) {}
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FootageCollectorApp());
}

class ProjectModel {
  final String id;
  final String name;
  final String path;
  final String source;
  final DateTime createdAt;

  const ProjectModel({required this.id, required this.name, required this.path, required this.createdAt, this.source=""});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'path': path, 'source': source, 'createdAt': createdAt.toIso8601String()};
  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        id: json['id'] as String,
        name: json['name'] as String,
        path: json['path'] as String,
        source: '${json['source']??''}',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class ProjectStore {
  static const _key = 'footage_collector_projects_v1';
  static Future<List<ProjectModel>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List).map((e) => ProjectModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<ProjectModel> projects) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(projects.map((e) => e.toJson()).toList()));
  }
}


class AppSettingsStore {
  static const _ffmpegKey = 'footage_collector_ffmpeg_path_v1';
  static const _ytDlpKey = 'footage_collector_ytdlp_path_v1';
  static const _defaultDownloadKey = 'footage_collector_default_download_path_v1';
  static const _lastProjectKey = 'footage_collector_last_project_v1';
  static const _lastProjectAtKey = 'footage_collector_last_project_at_v1';
  static const _proxyModeKey = 'footage_collector_proxy_mode_v1';
  static const _proxyUrlKey = 'footage_collector_proxy_url_v1';
  static const _youtubeAuthModeKey = 'footageflow_youtube_auth_mode_v1';
  static const _youtubeBrowserKey = 'footageflow_youtube_browser_v1';
  static const _youtubeCookiesFileKey = 'footageflow_youtube_cookies_file_v1';
  static Future<String> loadYoutubeAuthMode() async { final p=await SharedPreferences.getInstance(); return p.getString(_youtubeAuthModeKey) ?? 'none'; }
  static Future<String> loadYoutubeBrowser() async { final p=await SharedPreferences.getInstance(); return p.getString(_youtubeBrowserKey) ?? 'chrome'; }
  static Future<String?> loadYoutubeCookiesFile() async { final p=await SharedPreferences.getInstance(); final v=p.getString(_youtubeCookiesFileKey)?.trim(); return (v==null||v.isEmpty)?null:v; }
  static Future<void> saveYoutubeAuth(String mode, String browser, String? cookiesFile) async { final p=await SharedPreferences.getInstance(); await p.setString(_youtubeAuthModeKey,mode); await p.setString(_youtubeBrowserKey,browser); if(cookiesFile==null||cookiesFile.trim().isEmpty) await p.remove(_youtubeCookiesFileKey); else await p.setString(_youtubeCookiesFileKey,cookiesFile.trim()); }
  static Future<String> loadProxyMode() async { final p=await SharedPreferences.getInstance(); return p.getString(_proxyModeKey) ?? 'system'; }
  static Future<String?> loadProxyUrl() async { final p=await SharedPreferences.getInstance(); final v=p.getString(_proxyUrlKey)?.trim(); return (v==null||v.isEmpty)?null:v; }
  static Future<void> saveProxy(String mode, String? url) async { final p=await SharedPreferences.getInstance(); await p.setString(_proxyModeKey, mode); if(url==null||url.trim().isEmpty) await p.remove(_proxyUrlKey); else await p.setString(_proxyUrlKey,url.trim()); }
  static Future<String?> loadYtDlpPath() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_ytDlpKey)?.trim();
    return (value == null || value.isEmpty) ? null : value;
  }
  static Future<void> saveYtDlpPath(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null || value.trim().isEmpty) { await prefs.remove(_ytDlpKey); }
    else { await prefs.setString(_ytDlpKey, value.trim()); }
  }
  static Future<String?> loadFfmpegPath() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_ffmpegKey)?.trim();
    return (value == null || value.isEmpty) ? null : value;
  }
  static Future<String?> loadDefaultDownloadPath() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_defaultDownloadKey)?.trim();
    return (value == null || value.isEmpty) ? null : value;
  }
  static Future<void> saveDefaultDownloadPath(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null || value.trim().isEmpty) { await prefs.remove(_defaultDownloadKey); }
    else { await prefs.setString(_defaultDownloadKey, value.trim()); }
  }
  static Future<void> saveRecentProject(String? projectId) async {
    final prefs = await SharedPreferences.getInstance();
    if (projectId == null || projectId.isEmpty) {
      await prefs.remove(_lastProjectKey); await prefs.remove(_lastProjectAtKey); return;
    }
    await prefs.setString(_lastProjectKey, projectId);
    await prefs.setInt(_lastProjectAtKey, DateTime.now().millisecondsSinceEpoch);
  }
  static Future<String?> loadRecentProject() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_lastProjectKey);
    final at = prefs.getInt(_lastProjectAtKey);
    if (id == null || at == null) return null;
    if (DateTime.now().millisecondsSinceEpoch - at > const Duration(minutes: 10).inMilliseconds) {
      await prefs.remove(_lastProjectKey); await prefs.remove(_lastProjectAtKey); return null;
    }
    return id;
  }
  static Future<void> saveFfmpegPath(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null || value.trim().isEmpty) {
      await prefs.remove(_ffmpegKey);
    } else {
      await prefs.setString(_ffmpegKey, value.trim());
    }
  }
}


class LibraryItem {
  final String id, title, filePath, projectId, projectName, formatLabel;
  final String? thumbnail, collection, sourceUrl, outputMode, clipStart, clipEnd;
  final List<String> tags;
  final int sizeBytes;
  final DateTime addedAt;
  final bool favorite;
  const LibraryItem({required this.id, required this.title, required this.filePath, required this.projectId, required this.projectName, required this.formatLabel, this.thumbnail, this.collection, this.sourceUrl, this.outputMode, this.clipStart, this.clipEnd, this.tags=const [], required this.sizeBytes, required this.addedAt, this.favorite=false});
  Map<String,dynamic> toJson()=>{'id':id,'title':title,'filePath':filePath,'projectId':projectId,'projectName':projectName,'formatLabel':formatLabel,'thumbnail':thumbnail,'collection':collection,'sourceUrl':sourceUrl,'outputMode':outputMode,'clipStart':clipStart,'clipEnd':clipEnd,'tags':tags,'sizeBytes':sizeBytes,'addedAt':addedAt.toIso8601String(),'favorite':favorite};
  factory LibraryItem.fromJson(Map<String,dynamic> j)=>LibraryItem(id:'${j['id']}',title:'${j['title']}',filePath:'${j['filePath']}',projectId:'${j['projectId']}',projectName:'${j['projectName']}',formatLabel:'${j['formatLabel']}',thumbnail:j['thumbnail'] as String?,collection:j['collection'] as String?,sourceUrl:j['sourceUrl'] as String?,outputMode:j['outputMode'] as String?,clipStart:j['clipStart'] as String?,clipEnd:j['clipEnd'] as String?,tags:(j['tags'] as List? ?? const []).map((e)=>'$e').toList(),sizeBytes:(j['sizeBytes'] as num?)?.toInt()??0,addedAt:DateTime.tryParse('${j['addedAt']}')??DateTime.now(),favorite:j['favorite']==true);
  LibraryItem copyWith({String? filePath,String? projectId,String? projectName,String? thumbnail,String? collection,bool clearCollection=false,bool? favorite,List<String>? tags})=>LibraryItem(id:id,title:title,filePath:filePath??this.filePath,projectId:projectId??this.projectId,projectName:projectName??this.projectName,formatLabel:formatLabel,thumbnail:thumbnail??this.thumbnail,collection:clearCollection?null:(collection??this.collection),sourceUrl:sourceUrl,outputMode:outputMode,clipStart:clipStart,clipEnd:clipEnd,sizeBytes:sizeBytes,addedAt:addedAt,favorite:favorite??this.favorite,tags:tags??this.tags);
}

Future<String?> _cacheThumbnailLocally(String? source, {String? videoPath}) async {
  try {
    final base='${Platform.environment['LOCALAPPDATA']??Directory.systemTemp.path}${Platform.pathSeparator}FootageCollector${Platform.pathSeparator}thumbnails';
    await Directory(base).create(recursive:true);
    if(source!=null && (source.startsWith('http://')||source.startsWith('https://'))){
      final uri=Uri.parse(source);
      final client=HttpClient()..connectionTimeout=const Duration(seconds:8);
      try{
        final req=await client.getUrl(uri);
        final res=await req.close();
        if(res.statusCode>=200&&res.statusCode<300){
          final bytes=await res.fold<List<int>>(<int>[],(a,b){a.addAll(b);return a;});
          if(bytes.isNotEmpty){
            final out='$base${Platform.pathSeparator}${DateTime.now().microsecondsSinceEpoch}.jpg';
            await File(out).writeAsBytes(bytes,flush:true);
            return out;
          }
        }
      } finally { client.close(force:true); }
    }
    if(source!=null && File(source).existsSync()) return source;
    if(videoPath!=null && File(videoPath).existsSync()){
      final ff=DownloaderEngine.ffmpegPath;
      if(ff.isNotEmpty&&File(ff).existsSync()){
        final out='$base${Platform.pathSeparator}${DateTime.now().microsecondsSinceEpoch}.jpg';
        final r=await Process.run(ff,['-y','-ss','00:00:01','-i',videoPath,'-frames:v','1','-q:v','2',out]);
        if(r.exitCode==0&&File(out).existsSync())return out;
      }
    }
  }catch(_){}
  return null;
}

class LibraryStore extends ChangeNotifier {
  static const _itemsKey='footage_collector_library_v1', _collectionsKey='footage_collector_collections_v1';
  List<LibraryItem> items=[];
  Map<String,List<String>> collections={};
  Future<void> load() async {
    final p=await SharedPreferences.getInstance();
    try {
      final r=p.getString(_itemsKey);
      if(r!=null) items=(jsonDecode(r) as List).map((e)=>LibraryItem.fromJson(Map<String,dynamic>.from(e))).toList();
      final c=p.getString(_collectionsKey);
      if(c!=null) collections=(jsonDecode(c) as Map<String,dynamic>).map((k,v)=>MapEntry(k,List<String>.from(v)));
      // Thumbnail repair is intentionally lazy. Startup must not scan the disk or launch FFmpeg.
    } catch(_){}
    notifyListeners();
  }
  Future<void> _save() async { final p=await SharedPreferences.getInstance(); await p.setString(_itemsKey,jsonEncode(items.map((e)=>e.toJson()).toList())); await p.setString(_collectionsKey,jsonEncode(collections)); notifyListeners(); }
  List<String> collectionsFor(String projectId)=>collections[projectId]??const [];
  Future<void> addCollection(String projectId,String name) async { final n=name.trim(); if(n.isEmpty)return; final list=[...(collections[projectId]??const <String>[])]; if(!list.any((e)=>e.toLowerCase()==n.toLowerCase())){list.add(n);collections[projectId]=list;await _save();} }
  Future<void> renameCollection(String projectId,String oldName,String newName) async { final n=newName.trim(); if(n.isEmpty)return; final list=[...(collections[projectId]??const <String>[])]; if(list.any((e)=>e.toLowerCase()==n.toLowerCase()&&e.toLowerCase()!=oldName.toLowerCase()))return; final idx=list.indexOf(oldName); if(idx<0)return; list[idx]=n; collections[projectId]=list; for(var i=0;i<items.length;i++){final e=items[i];if(e.projectId==projectId&&e.collection==oldName){items[i]=LibraryItem(id:e.id,title:e.title,filePath:e.filePath,projectId:e.projectId,projectName:e.projectName,formatLabel:e.formatLabel,thumbnail:e.thumbnail,collection:n,sourceUrl:e.sourceUrl,outputMode:e.outputMode,clipStart:e.clipStart,clipEnd:e.clipEnd,sizeBytes:e.sizeBytes,addedAt:e.addedAt,favorite:e.favorite,tags:e.tags);}} await _save(); }
  Future<void> deleteCollection(String projectId,String name) async { final list=[...(collections[projectId]??const <String>[])]; list.remove(name); collections[projectId]=list; for(var i=0;i<items.length;i++){final e=items[i];if(e.projectId==projectId&&e.collection==name){items[i]=LibraryItem(id:e.id,title:e.title,filePath:e.filePath,projectId:e.projectId,projectName:e.projectName,formatLabel:e.formatLabel,thumbnail:e.thumbnail,collection:null,sourceUrl:e.sourceUrl,outputMode:e.outputMode,clipStart:e.clipStart,clipEnd:e.clipEnd,sizeBytes:e.sizeBytes,addedAt:e.addedAt,favorite:e.favorite,tags:e.tags);}} await _save(); }
  Future<void> updateThumbnail(LibraryItem item,String thumbnail) async {
    final i=items.indexWhere((e)=>e.id==item.id);
    if(i<0)return;
    items[i]=items[i].copyWith(thumbnail:thumbnail);
    await _save();
  }
  Future<void> updateTags(LibraryItem item,List<String> tags) async { final i=items.indexWhere((e)=>e.id==item.id); if(i<0)return; items[i]=items[i].copyWith(tags:tags); await _save(); }
  Future<void> renameProject(String id,String name) async { for(var i=0;i<items.length;i++){if(items[i].projectId==id)items[i]=items[i].copyWith(projectName:name);} await _save(); }
  Future<void> addItem(LibraryItem item) async { if(items.any((e)=>e.filePath.toLowerCase()==item.filePath.toLowerCase()))return; items.insert(0,item); await _save(); }
  Future<void> replaceDownloadedItem(LibraryItem item,{String? sourceUrl}) async {
    final src=(sourceUrl??item.sourceUrl??'').trim();
    items.removeWhere((e)=>e.filePath.toLowerCase()==item.filePath.toLowerCase() || (src.isNotEmpty && (e.sourceUrl??'').trim()==src));
    items.insert(0,item);
    await _save();
  }
  Future<int> addItems(Iterable<LibraryItem> incoming) async { final known=items.map((e)=>e.filePath.toLowerCase()).toSet(); final fresh=<LibraryItem>[]; for(final item in incoming){if(known.add(item.filePath.toLowerCase()))fresh.add(item);} if(fresh.isEmpty)return 0; items.insertAll(0,fresh.reversed); await _save(); return fresh.length; }
  Future<void> toggleFavorite(LibraryItem item) async { final i=items.indexWhere((e)=>e.id==item.id); if(i<0)return; items[i]=items[i].copyWith(favorite:!items[i].favorite); await _save(); }
  Future<void> moveToCollection(LibraryItem item,String? collection) async { final i=items.indexWhere((e)=>e.id==item.id); if(i<0)return; items[i]=LibraryItem(id:item.id,title:item.title,filePath:item.filePath,projectId:item.projectId,projectName:item.projectName,formatLabel:item.formatLabel,thumbnail:item.thumbnail,collection:collection,sourceUrl:item.sourceUrl,outputMode:item.outputMode,clipStart:item.clipStart,clipEnd:item.clipEnd,sizeBytes:item.sizeBytes,addedAt:item.addedAt,favorite:item.favorite,tags:item.tags); await _save(); }
  Future<void> updateMovedItem(LibraryItem item,{required String filePath,required ProjectModel project,String? collection}) async { final i=items.indexWhere((e)=>e.id==item.id); if(i<0)return; items[i]=item.copyWith(filePath:filePath,projectId:project.id,projectName:project.name,thumbnail:item.thumbnail==item.filePath?filePath:item.thumbnail,collection:collection,clearCollection:collection==null); await _save(); }
  Future<void> relocateProject(ProjectModel oldProject, ProjectModel newProject) async {
    String remap(String value) {
      final oldPath=oldProject.path;
      if(value.toLowerCase()==oldPath.toLowerCase() || value.toLowerCase().startsWith('${oldPath.toLowerCase()}${Platform.pathSeparator}')) return newProject.path+value.substring(oldPath.length);
      return value;
    }
    for(var i=0;i<items.length;i++){
      final e=items[i];
      if(e.projectId==oldProject.id){
        items[i]=LibraryItem(id:e.id,title:e.title,filePath:remap(e.filePath),projectId:newProject.id,projectName:newProject.name,formatLabel:e.formatLabel,thumbnail:e.thumbnail==null?null:remap(e.thumbnail!),collection:e.collection,sourceUrl:e.sourceUrl,outputMode:e.outputMode,clipStart:e.clipStart,clipEnd:e.clipEnd,sizeBytes:e.sizeBytes,addedAt:e.addedAt,favorite:e.favorite,tags:e.tags);
      }
    }
    await _save();
  }
  Future<void> removeProjects(Set<String> projectIds) async { items.removeWhere((e)=>projectIds.contains(e.projectId)); for(final id in projectIds){collections.remove(id);} await _save(); }
  Future<void> remove(LibraryItem item,{bool deleteFile=false}) async { if(deleteFile){try{final f=File(item.filePath);if(await f.exists())await f.delete();}catch(_){}} items.removeWhere((e)=>e.id==item.id); await _save(); }
}

class FootageCollectorApp extends StatelessWidget {
  const FootageCollectorApp({super.key});
  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0B0D12);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FootageFlow',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(primary: Color(0xFF8B5CF6), secondary: Color(0xFF22D3EE), surface: Color(0xFF13161D)),
        useMaterial3: true,
        cardTheme: const CardThemeData(color: Color(0xFF13161D), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16)), side: BorderSide(color: Color(0xFF242833)))),
        inputDecorationTheme: const InputDecorationTheme(filled: true, fillColor: Color(0xFF10131A), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Color(0xFF292E3A))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Color(0xFF292E3A)))),
      ),
      home: const AppShell(),
    );
  }
}


/// Bring the Windows runner forward after an authenticated Chrome link.
class FootageFlowWindowFocus {
  static const preferenceKey = 'footageflow_focus_on_chrome_link_v1';
  static const MethodChannel _channel = MethodChannel('footageflow/window_focus');

  static Future<void> activate() async {
    if (!Platform.isWindows) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!(prefs.getBool(preferenceKey) ?? true)) {
        debugPrint('[FootageFlow Focus] Disabled in Settings');
        return;
      }
      final result = await _channel.invokeMapMethod<String, dynamic>('activate');
      debugPrint('[FootageFlow Focus] Initial activation: $result');
      // Chrome may reclaim the foreground after its context menu closes.
      await Future<void>.delayed(const Duration(milliseconds: 350));
      final after = await _channel.invokeMapMethod<String, dynamic>('inspect');
      debugPrint('[FootageFlow Focus] After 350ms: $after');
      if (after?['focused'] != true || after?['topOfZOrder'] != true) {
        final retry = await _channel.invokeMapMethod<String, dynamic>('activate');
        debugPrint('[FootageFlow Focus] Delayed activation: $retry');
      }
      await Future<void>.delayed(const Duration(milliseconds: 450));
      final finalState = await _channel.invokeMapMethod<String, dynamic>('inspect');
      debugPrint('[FootageFlow Focus] Final state after 800ms: $finalState');
    } catch (error, stack) {
      debugPrint('[FootageFlow Focus] Native call failed: $error');
      debugPrintStack(stackTrace: stack);
    }
  }
}

/// Loopback-only Chrome bridge. A user must approve every new extension ID.
class FootageFlowChromeBridge {
  static HttpServer? _server;
  static final ValueNotifier<String?> incomingUrl = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> pairingRequest = ValueNotifier<String?>(null);
  static final ValueNotifier<bool> online = ValueNotifier<bool>(false);
  static final Map<String, String> _tokens = {};
  static final Map<String, String> _pending = {};
  static final Map<String, DateTime> _requestedAt = {};
  static final Random _random = Random.secure();
  static String _secret() => List.generate(32, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();

  static Future<void> approve(String origin) async {
    if (!_pending.containsKey(origin)) return;
    final token = _secret();
    _tokens[origin] = token;
    _pending.remove(origin);
    _requestedAt.remove(origin);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('footageflow_extension_tokens_v2', jsonEncode(_tokens));
    pairingRequest.value = null;
  }
  static void reject(String origin) {
    _pending.remove(origin);
    _requestedAt.remove(origin);
    pairingRequest.value = null;
  }
  static Future<void> revokeAll() async {
    _tokens.clear(); _pending.clear(); _requestedAt.clear(); pairingRequest.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('footageflow_extension_tokens_v2');
  }
  static Future<void> start() async {
    if (!Platform.isWindows || _server != null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('footageflow_extension_tokens_v2');
      if (stored != null) {
        final data = jsonDecode(stored);
        if (data is Map) {
          for (final e in data.entries) {
            if (e.key is String && e.value is String) _tokens[e.key as String] = e.value as String;
          }
        }
      }
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8788);
      online.value = true;
      _server!.listen((request) async {
        final res = request.response;
        res.headers.set('Cache-Control', 'no-store');
        res.headers.contentType = ContentType.json;
        // Chrome extension fetch() may omit Origin on same-context requests.
        // The extension identifies itself with a custom header. Browser pages
        // cannot send this header unless their CORS preflight is approved.
        final browserOrigin = request.headers.value('origin') ?? '';
        final claimedId = request.headers.value('X-FootageFlow-Extension-Id') ?? '';
        final validId = RegExp(r'^[a-p]{32}$').hasMatch(claimedId);
        final claimedOrigin = validId ? 'chrome-extension://$claimedId' : '';
        final origin = browserOrigin.isEmpty ? claimedOrigin : browserOrigin;
        final allowed = validId && origin == claimedOrigin;
        if (allowed) {
          res.headers.set('Access-Control-Allow-Origin', origin);
          res.headers.set('Vary', 'Origin');
          res.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
          res.headers.set('Access-Control-Allow-Headers', 'Content-Type, X-FootageFlow-Token, X-FootageFlow-Extension-Id');
        }
        void reply(int code, Map<String, dynamic> data) { res.statusCode = code; res.write(jsonEncode(data)); }
        if (!allowed) { reply(403, {'error':'Forbidden'}); await res.close(); return; }
        if (request.method == 'OPTIONS') { res.statusCode = 204; await res.close(); return; }
        final path = request.uri.path;
        final token = request.headers.value('X-FootageFlow-Token');
        final authenticated = _tokens[origin] != null && _tokens[origin] == token;
        if (path == '/status' && request.method == 'GET') {
          reply(200, {'connected': authenticated});
        } else if (path == '/pair/request' && request.method == 'POST') {
          if (authenticated) { reply(200, {'status':'connected'}); }
          else {
            final last = _requestedAt[origin];
            if (last == null || DateTime.now().difference(last).inSeconds > 30) {
              _pending[origin] = _secret();
              _requestedAt[origin] = DateTime.now();
              pairingRequest.value = origin;
            }
            reply(200, {'status':'pending'});
          }
        } else if (path == '/pair/status' && request.method == 'GET') {
          // Pairing credential is only handed to the extension ID approved by the user.
          if (_tokens.containsKey(origin) && !_pending.containsKey(origin)) {
            reply(200, {'status':'connected','token':_tokens[origin]});
          } else if (_pending.containsKey(origin)) {
            reply(200, {'status':'pending'});
          } else { reply(200, {'status':'unpaired'}); }
        } else if (path == '/inbox' && request.method == 'POST' && authenticated) {
          try {
            final body = await utf8.decoder.bind(request).join();
            if (body.length > 4096) throw const FormatException('Too large');
            final data = jsonDecode(body);
            if (data is! Map || data['url'] is! String) throw const FormatException('Invalid data');
            final url = (data['url'] as String).trim();
            final uri = Uri.tryParse(url);
            if (uri == null || !['http','https'].contains(uri.scheme) || uri.host.isEmpty || uri.userInfo.isNotEmpty || url.length > 2048) throw const FormatException('Invalid URL');
            incomingUrl.value = url;
            reply(200, {'ok':true});
          } catch (_) { reply(400, {'error':'Invalid link'}); }
        } else { reply(403, {'error':'Not paired'}); }
        await res.close();
      });
    } catch (_) { online.value = false; }
  }
  static Future<void> stop() async { await _server?.close(force:true); _server=null; online.value=false; }
}

final ValueNotifier<int> footageFlowTourRequests = ValueNotifier<int>(0);

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  late final LibraryStore libraryStore;
  late final DownloadManager downloadManager;
  bool loading = true;
  bool tourVisible = false;
  bool languagePickerVisible = false;
  int tourStep = 0;
  List<ProjectModel> projects = [];
  ProjectModel? openedProject;

  @override
  void initState() {
    super.initState();
    libraryStore = LibraryStore();
    downloadManager = DownloadManager(libraryStore);
    footageFlowTourRequests.addListener(_restartTour);
    _load();
    FootageFlowChromeBridge.incomingUrl.addListener(_receiveChromeUrl);
    FootageFlowChromeBridge.pairingRequest.addListener(_onChromePairing);
  }

  void _onChromePairing() {
    final origin = FootageFlowChromeBridge.pairingRequest.value;
    if (origin == null || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || FootageFlowChromeBridge.pairingRequest.value != origin) return;
      final accepted = await showDialog<bool>(context: context, barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Connect Chrome extension?'),
          content: Text('A Chrome extension is requesting access to send video links to FootageFlow.\n\nExtension ID: ${origin.replaceFirst('chrome-extension://', '')}\n\nOnly approve if you just requested this connection in Chrome.'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Reject')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Allow connection'))]));
      if (accepted == true) { await FootageFlowChromeBridge.approve(origin); }
      else { FootageFlowChromeBridge.reject(origin); }
    });
  }

  void _receiveChromeUrl() { if (FootageFlowChromeBridge.incomingUrl.value != null && mounted) { setState(() { index = 2; openedProject = null; }); WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) unawaited(FootageFlowWindowFocus.activate()); }); } }

  void _restartTour() { if (mounted) setState(() { tourStep = 0; tourVisible = true; index = 0; openedProject = null; }); }
  Future<void> _selectFirstLanguage(String code) async { final prefs = await SharedPreferences.getInstance(); await prefs.setString("footageflow_language_v1", code); footageFlowLanguage.value = code; if (mounted) setState(() { languagePickerVisible = false; tourVisible = !(prefs.getBool("footageflow_tour_completed_v1") ?? false); }); }
  Future<void> _endTour() async { final prefs = await SharedPreferences.getInstance(); await prefs.setBool('footageflow_tour_completed_v1', true); if (mounted) setState(() => tourVisible = false); }
  void _nextTour() { if (tourStep == 5) { _endTour(); return; } setState(() { tourStep++; index = [0,1,2,3,6,0][tourStep]; openedProject = null; }); }
  @override void dispose() { footageFlowTourRequests.removeListener(_restartTour); FootageFlowChromeBridge.incomingUrl.removeListener(_receiveChromeUrl); FootageFlowChromeBridge.pairingRequest.removeListener(_onChromePairing); FootageFlowChromeBridge.stop(); super.dispose(); }

  Future<void> _load() async {
    projects = await ProjectStore.load();
    DownloaderEngine.configuredFfmpegPath = await AppSettingsStore.loadFfmpegPath();
    DownloaderEngine.configuredYtDlpPath = await AppSettingsStore.loadYtDlpPath();
    await libraryStore.load();
    await downloadManager.loadHistory();
    await FootageFlowChromeBridge.start();
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('footageflow_language_v1');
    footageFlowLanguage.value = savedLanguage == 'fa' ? 'fa' : 'en';
    final firstRun = !(prefs.getBool('footageflow_tour_completed_v1') ?? false);
    if (mounted) setState(() { loading = false; languagePickerVisible = savedLanguage == null; tourVisible = firstRun && savedLanguage != null; });
  }

  Future<void> _createProject() async {
    final nameController = TextEditingController();
    String? basePath;
    String? error;
    final created = await showDialog<ProjectModel>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) {
        Future<void> pickFolder() async {
          final result = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Choose footage library folder');
          if (result != null) setDialogState(() => basePath = result);
        }

        Future<void> submit() async {
          final name = nameController.text.trim();
          if (name.isEmpty) {
            setDialogState(() => error = 'Enter a project name.');
            return;
          }
          if (basePath == null) {
            setDialogState(() => error = 'Choose where this project should be stored.');
            return;
          }
          final invalid = RegExp(r'[<>:"/\\|?*]');
          if (invalid.hasMatch(name)) {
            setDialogState(() => error = 'Project name contains a character Windows cannot use in a folder name.');
            return;
          }
          final projectPath = '$basePath${Platform.pathSeparator}$name';
          final dir = Directory(projectPath);
          if (await dir.exists()) {
            setDialogState(() => error = 'A folder with this project name already exists there.');
            return;
          }
          try {
            await dir.create(recursive: true);
            for (final folder in ['Footages', 'Images', 'Downloads']) {
              await Directory('$projectPath${Platform.pathSeparator}$folder').create(recursive: true);
            }
            final project = ProjectModel(id: DateTime.now().microsecondsSinceEpoch.toString(), name: name, path: projectPath, createdAt: DateTime.now());
            if (dialogContext.mounted) Navigator.pop(dialogContext, project);
          } catch (e) {
            setDialogState(() => error = 'Could not create the project folder. Check folder permissions.');
          }
        }

        return AlertDialog(
          title: const Text('Create new project'),
          content: SizedBox(width: 520, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Project name', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(controller: nameController, autofocus: true, decoration: InputDecoration(hintText: ffTranslate('e.g. Madara Edit'))),
            const SizedBox(height: 18),
            const Text('Save location', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            InkWell(onTap: pickFolder, borderRadius: BorderRadius.circular(12), child: Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF10131A), border: Border.all(color: const Color(0xFF292E3A)), borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.folder_open_rounded, color: Color(0xFF8B5CF6)), const SizedBox(width: 12), Expanded(child: Text(basePath ?? 'Choose a folder...', overflow: TextOverflow.ellipsis, style: TextStyle(color: basePath == null ? const Color(0xFF858C9C) : Colors.white))), const Icon(Icons.chevron_right_rounded)]))),
            if (basePath != null && nameController.text.trim().isNotEmpty) ...[const SizedBox(height: 10), Text('Project folder: $basePath${Platform.pathSeparator}${nameController.text.trim()}', style: const TextStyle(color: Color(0xFF858C9C), fontSize: 12))],
            if (error != null) ...[const SizedBox(height: 12), Text(error!, style: const TextStyle(color: Color(0xFFFF6B6B)))],
          ])),
          actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')), FilledButton.icon(onPressed: submit, icon: const Icon(Icons.create_new_folder_rounded), label: const Text('Create project'))],
        );
      }),
    );
    nameController.dispose();
    if (created != null) {
      setState(() { projects = [created, ...projects]; openedProject = created; });
      await ProjectStore.save(projects);
    }
  }

  void _openProject(ProjectModel p) => setState(() => openedProject = p);

  Future<void> _replaceProjects(List<ProjectModel> value) async {
    if (!mounted) return;
    setState(() {
      projects = value;
      if (openedProject != null) {
        final match = value.where((p) => p.id == openedProject!.id).toList();
        openedProject = match.isEmpty ? null : match.first;
      }
    });
    await ProjectStore.save(projects);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(projects: projects, loading: loading, libraryStore: libraryStore, downloadManager: downloadManager, onNewProject: _createProject, onOpenProject: _openProject),
      ProjectsPage(projects: projects, libraryStore: libraryStore, onNewProject: _createProject, onOpenProject: _openProject, onProjectsChanged: _replaceProjects),
      UniversalDownloaderPage(projects: projects, downloadManager: downloadManager),
      LibraryPage(store: libraryStore, projects: projects),
      DownloadsPage(manager: downloadManager, projects: projects),
      ShareCenterPage(store: libraryStore, projects: projects, manager: downloadManager),
      const SettingsPage(),
    ];
    return ValueListenableBuilder<String>(valueListenable: footageFlowLanguage, builder: (context, language, _) => Directionality(textDirection: language == "fa" ? TextDirection.rtl : TextDirection.ltr, child: Scaffold(body: Stack(children: [Row(children: [
      NavigationRail(
        backgroundColor: const Color(0xFF0F1117), extended: MediaQuery.sizeOf(context).width >= 1050, minExtendedWidth: 220, selectedIndex: index,
        onDestinationSelected: (v) => setState(() { index = v; openedProject = null; }),
        leading: Padding(padding: const EdgeInsets.fromLTRB(10, 18, 10, 24), child: Row(mainAxisSize: MainAxisSize.min, children: [ClipRRect(borderRadius: BorderRadius.circular(11), child: Image.asset('assets/icon/footageflow.png', width: 38, height: 38, fit: BoxFit.cover)), if (MediaQuery.sizeOf(context).width >= 1050) ...[const SizedBox(width: 12), const Text('FootageFlow', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))]])),
        destinations: const [NavigationRailDestination(icon: Icon(Icons.space_dashboard_outlined), selectedIcon: Icon(Icons.space_dashboard_rounded), label: Text('Home')), NavigationRailDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder_rounded), label: Text('Projects')), NavigationRailDestination(icon: Icon(Icons.inbox_outlined), selectedIcon: Icon(Icons.inbox_rounded), label: Text('Inbox')), NavigationRailDestination(icon: Icon(Icons.video_library_outlined), selectedIcon: Icon(Icons.video_library_rounded), label: Text('Library')), NavigationRailDestination(icon: Icon(Icons.downloading_outlined), selectedIcon: Icon(Icons.downloading_rounded), label: Text('Downloads')), NavigationRailDestination(icon: Icon(Icons.ios_share_outlined), selectedIcon: Icon(Icons.ios_share_rounded), label: Text('Share')), NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: Text('Settings'))],
      ),
      const VerticalDivider(width: 1, thickness: 1, color: Color(0xFF20242E)),
      Expanded(child: openedProject != null
          ? ProjectDetailPage(project: openedProject!, projects: projects, libraryStore: libraryStore, onBack: () => setState(() => openedProject = null))
          : IndexedStack(index: index, children: pages)),
    ]), if (languagePickerVisible) Positioned.fill(child: _FootageFlowLanguagePicker(onSelect: _selectFirstLanguage)), if (!tourVisible && !languagePickerVisible && index == 6) Positioned(right: 20, bottom: 20, child: FloatingActionButton.extended(onPressed: _restartTour, icon: const Icon(Icons.school_rounded), label: const Text('Replay tutorial'))), if (tourVisible) Positioned.fill(child: _FootageFlowTour(step: tourStep, onSkip: _endTour, onNext: _nextTour, onBack: () => setState(() { tourStep--; index = [0,1,2,3,6,0][tourStep]; }))) ]))));
  }
}


class _FootageFlowLanguagePicker extends StatelessWidget {
  final Future<void> Function(String) onSelect;
  const _FootageFlowLanguagePicker({required this.onSelect});
  @override Widget build(BuildContext context) => Material(
    color: const Color(0xF90B0D15),
    child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460),
      child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.language_rounded, size: 60, color: Color(0xFF8B5CF6)),
        const SizedBox(height: 22),
        const fm.Text('Choose your language / زبان برنامه را انتخاب کنید', textAlign: TextAlign.center, style: fm.TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const fm.Text('You can change this later in Settings. / بعداً از تنظیمات قابل تغییر است.', textAlign: TextAlign.center, style: fm.TextStyle(color: Color(0xFFAAB0C0))),
        const SizedBox(height: 30),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => onSelect('en'), icon: const Icon(Icons.translate), label: const fm.Text('English'), style: FilledButton.styleFrom(padding: const EdgeInsets.all(18)))),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => onSelect('fa'), icon: const Icon(Icons.language), label: const fm.Text('فارسی'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(18)))),
      ])))));
}

class _FootageFlowTour extends StatelessWidget {
  final int step;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final VoidCallback onBack;
  const _FootageFlowTour({required this.step, required this.onSkip, required this.onNext, required this.onBack});
  static const titles = ['Welcome to FootageFlow', 'Create your first project', 'Download footage', 'Build your library', 'Configure your tools', 'Ready to create!'];
  static const details = [
    'Your creative workspace for collecting, organizing and sharing footage. Take a quick tour, or skip and explore.',
    'Open Projects to create a workspace. Choose a name and location; FootageFlow organizes your footage into folders.',
    'Open Inbox, paste a video link, then choose video, audio or a time range. Downloads can be managed in the queue.',
    'Search your footage, group it into collections, and drag files directly into your editing workflow.',
    'In Settings, choose yt-dlp and FFmpeg executables if needed. You can configure proxy and YouTube authentication here too.',
    'You can revisit this guide any time from Settings. Enjoy your workflow!'
  ];
  static const icons = [Icons.auto_awesome_rounded, Icons.create_new_folder_rounded, Icons.download_rounded, Icons.video_library_rounded, Icons.tune_rounded, Icons.check_circle_rounded];
  @override Widget build(BuildContext context) => Material(color: Colors.black.withValues(alpha: .77), child: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(18), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 540), child: Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: const Color(0xFF151925), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF47416F)), boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: .16), blurRadius: 40)]), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset('assets/icon/footageflow.png', width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.movie_filter_rounded, size: 48, color: Color(0xFF8B5CF6)))), const Spacer(), Text('STEP ${step + 1} / 6', style: const TextStyle(color: Color(0xFFA8A0CE), fontWeight: FontWeight.w700))]),
    const SizedBox(height: 22), Icon(icons[step], size: 38, color: const Color(0xFF22D3EE)), const SizedBox(height: 14), Text(titles[step], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)), const SizedBox(height: 12), Text(details[step], style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFFB9C0D0))), const SizedBox(height: 24), Row(children: List.generate(6, (i) => Expanded(child: Container(height: 5, margin: const EdgeInsets.only(right: 5), decoration: BoxDecoration(color: i <= step ? const Color(0xFF8B5CF6) : const Color(0xFF303448), borderRadius: BorderRadius.circular(5)))))), const SizedBox(height: 25), Row(children: [TextButton(onPressed: onSkip, child: const Text('Skip tour')), const Spacer(), if (step > 0) TextButton(onPressed: onBack, child: const Text('Back')), const SizedBox(width: 8), FilledButton.icon(onPressed: onNext, icon: Icon(step == 5 ? Icons.check_rounded : Icons.arrow_forward_rounded), label: Text(step == 5 ? 'Get started' : 'Next'))])
  ])))))));
}

class DashboardPage extends StatelessWidget {
  final List<ProjectModel> projects; final bool loading; final LibraryStore libraryStore; final DownloadManager downloadManager; final VoidCallback onNewProject; final ValueChanged<ProjectModel> onOpenProject;
  const DashboardPage({super.key, required this.projects, required this.loading, required this.libraryStore, required this.downloadManager, required this.onNewProject, required this.onOpenProject});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Good evening', style: TextStyle(color: Color(0xFF9298A8), fontSize: 14)), SizedBox(height: 4), Text('Your footage workspace', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800))])), FilledButton.icon(onPressed: onNewProject, icon: const Icon(Icons.add_rounded), label: const Text('New project'))]),
    const SizedBox(height: 28), AnimatedBuilder(animation: Listenable.merge([libraryStore, downloadManager]), builder: (context, _) { final footageCount=libraryStore.items.length; final downloadCount=downloadManager.tasks.isNotEmpty?downloadManager.tasks.length:libraryStore.items.length; final totalBytes=libraryStore.items.fold<int>(0,(sum,e)=>sum+e.sizeBytes); return LayoutBuilder(builder: (context, c) { final cols = c.maxWidth > 900 ? 4 : c.maxWidth > 520 ? 2 : 1; return GridView.count(crossAxisCount: cols, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 2.25, children: [StatCard(icon: Icons.folder_rounded, label: 'Projects', value: '${projects.length}'), StatCard(icon: Icons.movie_rounded, label: 'Footages', value: '$footageCount'), StatCard(icon: Icons.downloading_rounded, label: 'Downloads', value: '$downloadCount'), StatCard(icon: Icons.storage_rounded, label: 'Library size', value: _size(totalBytes))]); }); }),
    const SizedBox(height: 26), const Text('Recent projects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), const SizedBox(height: 12),
    if (loading) const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())) else if (projects.isEmpty) EmptyProjects(onNewProject: onNewProject) else Wrap(spacing: 14, runSpacing: 14, children: projects.take(6).map((p) => ProjectCard(project: p, libraryStore: libraryStore, onTap: () => onOpenProject(p))).toList()),
  ]));
}

class ProjectsPage extends StatefulWidget {
  final List<ProjectModel> projects; final LibraryStore libraryStore; final VoidCallback onNewProject; final ValueChanged<ProjectModel> onOpenProject; final Future<void> Function(List<ProjectModel>) onProjectsChanged;
  const ProjectsPage({super.key, required this.projects, required this.libraryStore, required this.onNewProject, required this.onOpenProject, required this.onProjectsChanged});
  @override State<ProjectsPage> createState()=>_ProjectsPageState();
}
class _ProjectsPageState extends State<ProjectsPage>{
  String query=''; bool selecting=false; final Set<String> selected={};
  Future<void> _editProject(ProjectModel project) async {
    final name = TextEditingController(text: project.name);
    final location = TextEditingController(text: Directory(project.path).absolute.parent.path);
    final result = await showDialog<(String, String)>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(builder: (context, refresh) => AlertDialog(
        title: const Text('Edit project'),
        content: SizedBox(width: 470, child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, enabled: true, decoration: const InputDecoration(labelText: 'Project name')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: location, enabled: true, decoration: const InputDecoration(labelText: 'Save location (parent folder)', hintText: 'Folder containing the project'))),
            IconButton(tooltip: 'Browse folder', onPressed: () async {
              final chosen = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Choose project save location');
              if (chosen != null) location.text = chosen;
            }, icon: const Icon(Icons.folder_open_outlined)),
          ]),
          const SizedBox(height: 12),
          const Text('The project folder will match its name. Renaming or changing location moves all files; existing destinations are never overwritten.', style: TextStyle(fontSize: 12, color: Color(0xFF858C9C))),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, (name.text.trim(), location.text.trim())), child: const Text('Save')),
        ],
      )),
    );
    name.dispose(); location.dispose();
    if (result == null) return;
    if (result.$1.isEmpty || result.$2.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project name and save location are required.')));
      return;
    }
    if (widget.projects.any((p) => p.id != project.id && p.name.toLowerCase() == result.$1.toLowerCase())) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A project with that name already exists.')));
      return;
    }
    // Save location is the parent directory. The project folder follows its name.
    final newName = result.$1.trim();
    if (newName == '.' || newName == '..' ||
        RegExp(r'[<>:"/\\|?*]').hasMatch(newName) ||
        newName.endsWith('.') || newName.endsWith(' ')) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Windows folder name.')));
      return;
    }
    final parent = Directory(result.$2).absolute;
    final newPath = '${parent.path}${Platform.pathSeparator}$newName';
    final oldPath = Directory(project.path).absolute.path;
    final changed = newPath.toLowerCase() != oldPath.toLowerCase();
    final updatedProject = ProjectModel(
      id: project.id, name: newName,
      path: changed ? newPath : project.path,
      createdAt: project.createdAt, source: project.source);
    if (changed) {
      try {
        await _moveProjectSafely(project.path, newPath);
      } catch (error) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Project was not moved: $error')));
        return;
      }
    }
    try {
      // Keep library paths and project metadata in sync.
      if (changed) {
        await widget.libraryStore.relocateProject(project, updatedProject);
      } else {
        await widget.libraryStore.renameProject(project.id, newName);
      }
      final updated = widget.projects
          .map((p) => p.id == project.id ? updatedProject : p).toList();
      await widget.onProjectsChanged(updated);
      if (changed) {
        try {
          await Directory(project.path).delete(recursive: true);
        } catch (_) {
          // Original remains as a safe backup if Windows blocks deletion.
        }
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project updated successfully.')));
    } catch (error) {
      // Never delete the original if updating metadata fails.
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Original folder preserved. Could not update project records: $error')));
    }
  }

  Future<void> _moveProjectSafely(String from, String to) async {
    final source = Directory(from).absolute;
    final target = Directory(to).absolute;
    String normalized(String path) => path.replaceAll('\\', '/').replaceAll(RegExp(r'/+$'), '').toLowerCase();
    final src = normalized(source.path), dst = normalized(target.path);
    if (src == dst) return;
    if (dst.startsWith('$src/') || src.startsWith('$dst/')) throw StateError('Destination cannot be inside the source folder or its parent.');
    if (!await source.exists()) throw StateError('Source project folder does not exist.');
    if (await File(target.path).exists() || await target.exists()) throw StateError('Destination already exists. Choose an empty, unused folder path.');
    final parent = target.parent;
    if (!await parent.exists()) throw StateError('Destination parent folder does not exist.');
    // Copy to a temporary sibling first; the original is untouched until verification.
    final staging = Directory('${target.path}.footageflow-moving-${DateTime.now().microsecondsSinceEpoch}');
    try {
      await _copyDirectory(source, staging);
      Future<Map<String, int>> manifest(Directory dir) async {
        final result = <String, int>{};
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          final relative = entity.path.substring(dir.path.length);
          if (entity is File) result[relative] = await entity.length();
          else if (entity is Directory) result['$relative/'] = -1;
          else throw StateError('Unsupported file type in project: $relative');
        }
        return result;
      }
      final original = await manifest(source);
      final copied = await manifest(staging);
      if (original.length != copied.length || original.entries.any((e) => copied[e.key] != e.value)) {
        throw StateError('Verification failed; original files were kept.');
      }
      if (await target.exists()) throw StateError('Destination appeared during transfer.');
      await staging.rename(target.path);
      // Do not delete the original until project and library records are saved.
    } catch (_) {
      if (await staging.exists()) {
        try { await staging.delete(recursive: true); } catch (_) {}
      }
      rethrow;
    }
  }
  Future<void> _copyDirectory(Directory source,Directory target) async { await target.create(recursive:true); await for(final entity in source.list(recursive:false,followLinks:false)){ final name=entity.path.split(Platform.pathSeparator).last; final dest='${target.path}${Platform.pathSeparator}$name'; if(entity is Directory) await _copyDirectory(entity,Directory(dest)); else if(entity is File) await entity.copy(dest); } }
  Future<void> _moveSelected() async {
    if(selected.isEmpty)return; final base=await FilePicker.platform.getDirectoryPath(dialogTitle:'Move selected projects to...'); if(base==null||!mounted)return;
    var moved=0; final updated=[...widget.projects]; final failures=<String>[];
    for(final id in selected.toList()){
      final idx=updated.indexWhere((p)=>p.id==id); if(idx<0)continue; final old=updated[idx]; final destPath='$base${Platform.pathSeparator}${old.name}';
      if(Directory(destPath).existsSync()){failures.add('${old.name}: destination already exists');continue;}
      try{
        final src=Directory(old.path); if(!await src.exists()){failures.add('${old.name}: source folder missing');continue;}
        try{await src.rename(destPath);}catch(_){await _copyDirectory(src,Directory(destPath));await src.delete(recursive:true);}
        final np=ProjectModel(id:old.id,name:old.name,path:destPath,createdAt:old.createdAt,source:old.source); updated[idx]=np; await widget.libraryStore.relocateProject(old,np); moved++;
      }catch(e){failures.add('${old.name}: $e');}
    }
    await widget.onProjectsChanged(updated); if(!mounted)return; setState((){selected.clear();selecting=false;});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(failures.isEmpty?'Moved $moved project${moved==1?'':'s'}.':'Moved $moved. ${failures.length} failed.')));
  }
  Future<void> _deleteSelected() async {
    if(selected.isEmpty)return;
    final choice=await showDialog<String>(context:context,builder:(d)=>AlertDialog(title:Text('Delete ${selected.length} project${selected.length==1?'':'s'}?'),content:const Text('Choose whether to only remove the projects from Footage Collector, or also permanently delete their folders and files from Windows.'),actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('Cancel')),OutlinedButton(onPressed:()=>Navigator.pop(d,'remove'),child:const Text('Remove from app')),FilledButton(onPressed:()=>Navigator.pop(d,'files'),style:FilledButton.styleFrom(backgroundColor:const Color(0xFFFF5C5C)),child:const Text('Delete folders too'))])) ;
    if(choice==null)return; final ids=Set<String>.from(selected); final targets=widget.projects.where((p)=>ids.contains(p.id)).toList(); final failed=<String>[];
    if(choice=='files'){for(final p in targets){try{final dir=Directory(p.path);if(await dir.exists())await dir.delete(recursive:true);}catch(e){failed.add(p.name);}}}
    final removeIds=choice=='files'?ids.difference(targets.where((p)=>failed.contains(p.name)).map((p)=>p.id).toSet()):ids;
    final updated=widget.projects.where((p)=>!removeIds.contains(p.id)).toList(); await widget.libraryStore.removeProjects(removeIds); await widget.onProjectsChanged(updated); if(!mounted)return;
    setState((){selected.removeAll(removeIds);if(selected.isEmpty)selecting=false;}); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(failed.isEmpty?'Removed ${removeIds.length} project${removeIds.length==1?'':'s'}.':'${failed.length} project folder${failed.length==1?'':'s'} could not be deleted.')));
  }
  @override Widget build(BuildContext context){
    final q=query.trim().toLowerCase(); final shown=q.isEmpty?widget.projects:widget.projects.where((p)=>p.name.toLowerCase().contains(q)||p.path.toLowerCase().contains(q)).toList();
    return Padding(padding:const EdgeInsets.all(28),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      LayoutBuilder(builder:(context,c){final compact=c.maxWidth<760;final title=const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Projects',maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:28,fontWeight:FontWeight.w800)),SizedBox(height:5),Text('Everything you collect stays organized by edit.',maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(color:Color(0xFF8F96A6)))]);final actions=Wrap(spacing:8,runSpacing:8,crossAxisAlignment:WrapCrossAlignment.center,children:!selecting?[OutlinedButton.icon(onPressed:(){setState(()=>selecting=true);},icon:const Icon(Icons.checklist_rounded),label:const Text('Select')),FilledButton.icon(onPressed:widget.onNewProject,icon:const Icon(Icons.add_rounded),label:const Text('New project'))]:[Text('${selected.length} selected',style:const TextStyle(color:Color(0xFF8B5CF6),fontWeight:FontWeight.w700)),OutlinedButton.icon(onPressed:selected.isEmpty?null:_moveSelected,icon:const Icon(Icons.drive_file_move_outline),label:const Text('Move')),OutlinedButton.icon(onPressed:selected.isEmpty?null:_deleteSelected,icon:const Icon(Icons.delete_outline_rounded),label:const Text('Delete')),TextButton(onPressed:()=>setState((){selected.clear();selecting=false;}),child:const Text('Done'))]);return compact?Column(crossAxisAlignment:CrossAxisAlignment.start,children:[title,const SizedBox(height:12),Align(alignment:Alignment.centerRight,child:actions)]):Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:title),const SizedBox(width:24),Align(alignment:Alignment.topRight,child:actions)]);}),
      const SizedBox(height:20),TextField(onChanged:(v)=>setState(()=>query=v),decoration:InputDecoration(prefixIcon:Icon(Icons.search_rounded),hintText:ffTranslate('Search projects by name or path...'))),const SizedBox(height:20),
      if(selecting) Padding(padding:const EdgeInsets.only(bottom:12),child:Row(children:[TextButton.icon(onPressed:()=>setState((){final ids=shown.map((e)=>e.id).toSet();if(ids.every(selected.contains)){selected.removeAll(ids);}else{selected.addAll(ids);}}),icon:const Icon(Icons.select_all_rounded),label:Text(shown.isNotEmpty&&shown.every((p)=>selected.contains(p.id))?'Clear visible':'Select all visible'))])),
      Expanded(child:widget.projects.isEmpty?EmptyProjects(onNewProject:widget.onNewProject):shown.isEmpty?const Center(child:Text('No projects found',style:TextStyle(color:Color(0xFF8F96A6)))):SingleChildScrollView(child:Wrap(spacing:14,runSpacing:14,children:shown.map((p)=>ProjectCard(project:p,libraryStore:widget.libraryStore,selected:selecting&&selected.contains(p.id),selectionMode:selecting,onEdit:()=>_editProject(p),onTap:(){if(selecting){setState((){if(!selected.add(p.id))selected.remove(p.id);});}else{widget.onOpenProject(p);}})).toList())))
    ]));
  }
}

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final LibraryStore libraryStore;
  final VoidCallback onTap; final VoidCallback? onEdit; final bool selectionMode; final bool selected;
  const ProjectCard({super.key, required this.project, required this.libraryStore, required this.onTap, this.onEdit, this.selectionMode=false, this.selected=false});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: libraryStore, builder: (context, _) {
      final footageCount = libraryStore.items.where((e) => e.projectId == project.id).length;
      return SizedBox(
      width: 310,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),side: BorderSide(color:selected?const Color(0xFF8B5CF6):const Color(0xFF252A35),width:selected?2:1)),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(!selectionMode) Align(alignment:Alignment.centerRight,child:IconButton(tooltip:"Edit project",onPressed:onEdit,icon:const Icon(Icons.edit_outlined,size:19))),
                if(selectionMode) Align(alignment:Alignment.centerRight,child:Icon(selected?Icons.check_circle_rounded:Icons.radio_button_unchecked_rounded,color:selected?const Color(0xFF8B5CF6):const Color(0xFF858C9C))),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.folder_rounded, color: Color(0xFF8B5CF6)),
                ),
                const SizedBox(height: 18),
                Text(project.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 7),
                if(project.source.isNotEmpty) Text(project.source,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(color:Color(0xFF22D3EE),fontSize:12)),
                Text(project.path, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF858C9C), fontSize: 12)),
                const SizedBox(height: 18),
                Row(children: [
                  const Icon(Icons.movie_outlined, size: 16, color: Color(0xFF858C9C)),
                  const SizedBox(width: 6),
                  Text('$footageCount ${footageCount == 1 ? 'footage' : 'footages'}', style: const TextStyle(color: Color(0xFF858C9C), fontSize: 12)),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFF8B5CF6)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
    });
  }
}

class EmptyProjects extends StatelessWidget {
  final VoidCallback onNewProject; const EmptyProjects({super.key, required this.onNewProject});
  @override Widget build(BuildContext context) => Card(child: SizedBox(width: double.infinity, height: 230, child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.folder_open_rounded, size: 48, color: Colors.white.withValues(alpha: .25)), const SizedBox(height: 12), const Text('No projects yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 5), const Text('Create a project and start collecting footage.', style: TextStyle(color: Color(0xFF858C9C))), const SizedBox(height: 14), OutlinedButton.icon(onPressed: onNewProject, icon: const Icon(Icons.add_rounded), label: const Text('Create first project'))]))));
}

class ProjectDetailPage extends StatefulWidget { final ProjectModel project; final List<ProjectModel> projects; final LibraryStore libraryStore; final VoidCallback onBack; const ProjectDetailPage({super.key,required this.project,required this.projects,required this.libraryStore,required this.onBack}); @override State<ProjectDetailPage> createState()=>_ProjectDetailPageState(); }
class _ProjectDetailPageState extends State<ProjectDetailPage> {
  String? selectedCollection; bool selectionMode=false; final Set<String> selected={};
  final TextEditingController _projectSearchController=TextEditingController();
  String _projectSearch='';
  @override void dispose(){_projectSearchController.dispose();super.dispose();}
  void toggleSelection(LibraryItem item){setState((){selectionMode=true;if(!selected.add(item.id))selected.remove(item.id);if(selected.isEmpty)selectionMode=false;});}
  void clearSelection()=>setState((){selected.clear();selectionMode=false;});
  Map<String,dynamic> _shareEntry(LibraryItem e)=>{
    'title':e.title,
    'sourceUrl':e.sourceUrl,
    'formatLabel':e.formatLabel,
    'collection':e.collection,
    'mediaType':_libraryMediaType(e.filePath,e.formatLabel),
    'outputMode':e.outputMode??'Video + audio',
    'downloadMode':(e.clipStart?.isNotEmpty==true&&e.clipEnd?.isNotEmpty==true)?'clip':'full',
    'clipStart':e.clipStart,
    'clipEnd':e.clipEnd,
  };
  Future<void> shareSelected() async {
    final picked=widget.libraryStore.items.where((e)=>selected.contains(e.id)).toList();
    if(picked.isEmpty)return;
    final valid=picked.where((e)=>e.sourceUrl?.trim().isNotEmpty==true).toList();
    final excluded=picked.length-valid.length;
    if(valid.isEmpty){
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Nothing shareable. Selected local imports do not contain a source link.')));
      return;
    }
    final safe='${widget.project.name} selected'.replaceAll(RegExp(r'[<>:"/\\|?*]'),'_');
    final path=await FilePicker.platform.saveFile(dialogTitle:'Save selected footage share pack',fileName:'$safe.fcshare',type:FileType.custom,allowedExtensions:['fcshare']);
    if(path==null)return;
    final payload={
      'app':'Footage Collector','version':2,'createdAt':DateTime.now().toIso8601String(),
      'project':{'name':widget.project.name,'collections':widget.libraryStore.collectionsFor(widget.project.id)},
      'items':valid.map(_shareEntry).toList(),
    };
    final out=path.toLowerCase().endsWith('.fcshare')?path:'$path.fcshare';
    await File(out).writeAsString(const JsonEncoder.withIndent('  ').convert(payload),flush:true);
    if(!mounted)return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('${valid.length} item${valid.length==1?'':'s'} shared${excluded>0?' • $excluded local item${excluded==1?'':'s'} skipped':''}.')));
  }
  Future<void> deleteSelected() async {final list=widget.libraryStore.items.where((e)=>selected.contains(e.id)).toList();if(list.isEmpty)return;final action=await showDialog<String>(context:context,builder:(d)=>AlertDialog(title:Text('Delete ${list.length} selected item${list.length==1?'':'s'}?'),content:const Text('Remove only from Footage Collector, or also delete the actual files from disk?'),actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('Cancel')),OutlinedButton(onPressed:()=>Navigator.pop(d,'library'),child:const Text('Remove from app')),FilledButton(style:FilledButton.styleFrom(backgroundColor:const Color(0xFFFF5C5C)),onPressed:()=>Navigator.pop(d,'disk'),child:const Text('Delete files too'))]));if(action==null)return;for(final item in list){await widget.libraryStore.remove(item,deleteFile:action=='disk');}if(mounted)clearSelection();}
  Future<void> moveSelected() async {final list=widget.libraryStore.items.where((e)=>selected.contains(e.id)).toList();if(list.isEmpty)return;final targets=widget.projects.where((p)=>p.id!=widget.project.id).toList();if(targets.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Create another project first.')));return;}final target=await showDialog<ProjectModel>(context:context,builder:(d)=>AlertDialog(title:Text('Move ${list.length} selected item${list.length==1?'':'s'}'),content:SizedBox(width:400,child:Column(mainAxisSize:MainAxisSize.min,children:targets.map((p)=>ListTile(leading:const Icon(Icons.folder_rounded),title:Text(p.name),subtitle:Text(p.path,maxLines:1,overflow:TextOverflow.ellipsis),onTap:()=>Navigator.pop(d,p))).toList()))));if(target==null)return;String? collection;final cols=widget.libraryStore.collectionsFor(target.id);if(cols.isNotEmpty){collection=await showDialog<String>(context:context,builder:(d)=>SimpleDialog(title:const Text('Destination collection'),children:[SimpleDialogOption(onPressed:()=>Navigator.pop(d,'__none__'),child:const Text('Unsorted')),...cols.map((c)=>SimpleDialogOption(onPressed:()=>Navigator.pop(d,c),child:Text(c)))]));if(collection==null)return;if(collection=='__none__')collection=null;}var moved=0,skipped=0;for(final item in list){try{final src=File(item.filePath);if(!await src.exists())continue;await Directory(target.path).create(recursive:true);var dest='${target.path}${Platform.pathSeparator}${item.filePath.split(Platform.pathSeparator).last}';if(await File(dest).exists()){skipped++;continue;}try{await src.rename(dest);}catch(_){await src.copy(dest);await src.delete();}await widget.libraryStore.updateMovedItem(item,filePath:dest,project:target,collection:collection);moved++;}catch(_){}}if(mounted){clearSelection();ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$moved moved${skipped>0?' • $skipped skipped (same name exists)':''}.')));}}
  bool _dropHover=false; bool _dropImporting=false;
  static const _dropVideoExt={'mp4','mov','mkv','avi','webm','m4v','mpeg','mpg','wmv','flv'};
  static const _dropAudioExt={'mp3','wav','m4a','aac','flac','ogg','opus','wma','aiff','aif'};
  static const _dropImageExt={'png','jpg','jpeg','webp','bmp','gif','tif','tiff'};
  Future<void> _importDroppedFiles(List<dynamic> dropped) async {
    if (_dropImporting) return;
    _dropImporting = true;
    var added=0, duplicates=0;
    final unsupported=<String>[];
    try {
      // Snapshot the drop once. Scrolling/rebuilding cards must never re-run import validation.
      final paths=<String>[];
      final pending=<LibraryItem>[];
      for(final x in dropped){
        final path=('${x.path}').trim();
        if(path.isNotEmpty && !paths.any((p)=>p.toLowerCase()==path.toLowerCase())) paths.add(path);
      }
      for(final path in paths){
        try{
          final f=File(path);
          if(!await f.exists()) continue;
          final name=path.split(Platform.pathSeparator).last;
          final dot=name.lastIndexOf('.');
          final ext=(dot>=0?name.substring(dot+1):'').toLowerCase();
          final isVideo=_dropVideoExt.contains(ext), isAudio=_dropAudioExt.contains(ext), isImage=_dropImageExt.contains(ext);
          if(!isVideo&&!isAudio&&!isImage){unsupported.add(name);continue;}
          if(widget.libraryStore.items.any((e)=>e.filePath.toLowerCase()==path.toLowerCase())){duplicates++;continue;}
          String? thumb;
          if(isImage) thumb=path;
          else if(isVideo) thumb=await _cacheThumbnailLocally(null,videoPath:path);
          final stat=await f.stat();
          final title=dot>0?name.substring(0,dot):name;
          pending.add(LibraryItem(
            id:'import_${DateTime.now().microsecondsSinceEpoch}_${pending.length}', title:title, filePath:path,
            projectId:widget.project.id, projectName:widget.project.name,
            formatLabel:isVideo?'Video • ${ext.toUpperCase()}':isAudio?'Audio • ${ext.toUpperCase()}':'Image • ${ext.toUpperCase()}',
            thumbnail:thumb, collection:selectedCollection, sizeBytes:stat.size, addedAt:DateTime.now(),
          ));
        }catch(_){
          // A file that fails metadata/thumbnail work is not mislabeled as unsupported.
        }
      }
      added=await widget.libraryStore.addItems(pending);
    } finally {
      _dropImporting=false;
      if(mounted && _dropHover) setState(()=>_dropHover=false);
    }
    if(!mounted)return;
    // One summary only, and only directly after the drop. No warning for duplicates or rebuild/scroll.
    if(unsupported.isNotEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('${unsupported.length} unsupported file${unsupported.length==1?'':'s'} skipped.')));
    } else if(added>0){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$added file${added==1?'':'s'} imported into ${widget.project.name}${duplicates>0?' • $duplicates already imported':''}.')));
    }
  }

  Future<void> addCollection() async { final c=TextEditingController(); final name=await showDialog<String>(context:context,builder:(d)=>AlertDialog(title:const Text('New collection'),content:TextField(controller:c,autofocus:true,decoration:InputDecoration(hintText:ffTranslate('Jets, Smoke, Fight...'))),actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(d,c.text.trim()),child:const Text('Create'))])); c.dispose(); if(name!=null&&name.isNotEmpty) await widget.libraryStore.addCollection(widget.project.id,name); }
  Future<void> collectionMenu(String name,Offset pos) async { final overlay=Overlay.of(context).context.findRenderObject() as RenderBox; final v=await showMenu<String>(context:context,position:RelativeRect.fromRect(Rect.fromPoints(pos,pos),Offset.zero&overlay.size),items:const [PopupMenuItem(value:'rename',child:ListTile(leading:Icon(Icons.edit_rounded),title:Text('Rename collection'),dense:true,contentPadding:EdgeInsets.zero)),PopupMenuItem(value:'delete',child:ListTile(leading:Icon(Icons.delete_outline_rounded,color:Color(0xFFFF6B6B)),title:Text('Delete collection',style:TextStyle(color:Color(0xFFFF6B6B))),dense:true,contentPadding:EdgeInsets.zero))]); if(!mounted)return; if(v=='rename'){final c=TextEditingController(text:name);final n=await showDialog<String>(context:context,builder:(d)=>AlertDialog(title:const Text('Rename collection'),content:TextField(controller:c,autofocus:true),actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(d,c.text.trim()),child:const Text('Rename'))]));c.dispose();if(n!=null&&n.isNotEmpty){await widget.libraryStore.renameCollection(widget.project.id,name,n);if(selectedCollection==name)setState(()=>selectedCollection=n);}} if(v=='delete'){final ok=await showDialog<bool>(context:context,builder:(d)=>AlertDialog(title:const Text('Delete collection?'),content:Text('Footage inside “$name” will become Unsorted. Files will not be deleted.'),actions:[TextButton(onPressed:()=>Navigator.pop(d,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(d,true),style:FilledButton.styleFrom(backgroundColor:const Color(0xFFFF5C5C)),child:const Text('Delete'))]))??false;if(ok){await widget.libraryStore.deleteCollection(widget.project.id,name);if(selectedCollection==name)setState(()=>selectedCollection=null);}} }
  @override Widget build(BuildContext context)=>AnimatedBuilder(animation:widget.libraryStore,builder:(_,__) { final all=widget.libraryStore.items.where((e)=>e.projectId==widget.project.id).toList(); final cols=widget.libraryStore.collectionsFor(widget.project.id); final collectionItems=selectedCollection==null?all:all.where((e)=>e.collection==selectedCollection).toList(); final q=_projectSearch.trim().toLowerCase(); final items=q.isEmpty?collectionItems:collectionItems.where((e)=>e.title.toLowerCase().contains(q)||e.formatLabel.toLowerCase().contains(q)||e.tags.any((t)=>t.toLowerCase().contains(q))||(e.collection??'').toLowerCase().contains(q)||e.filePath.split(Platform.pathSeparator).last.toLowerCase().contains(q)).toList(); return DropTarget(onDragEntered:(_)=>setState(()=>_dropHover=true),onDragExited:(_)=>setState(()=>_dropHover=false),onDragDone:(d)=>_importDroppedFiles(d.files),child:Stack(children:[Padding(padding:const EdgeInsets.all(28),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[LayoutBuilder(builder:(context,c){final compact=c.maxWidth<820;final info=Row(crossAxisAlignment:CrossAxisAlignment.start,children:[IconButton(onPressed:widget.onBack,icon:const Icon(Icons.arrow_back_rounded)),const SizedBox(width:8),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(widget.project.name,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:28,fontWeight:FontWeight.w800)),Text(widget.project.path,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(color:Color(0xFF858C9C)))]))]);final allVisibleSelected=items.isNotEmpty&&items.every((e)=>selected.contains(e.id));final actions=Wrap(spacing:8,runSpacing:8,crossAxisAlignment:WrapCrossAlignment.center,children:selectionMode?[Text('${selected.length} selected',style:const TextStyle(fontWeight:FontWeight.w700)),OutlinedButton.icon(onPressed:items.isEmpty?null:()=>setState((){if(allVisibleSelected){selected.removeAll(items.map((e)=>e.id));}else{selected.addAll(items.map((e)=>e.id));}}),icon:Icon(allVisibleSelected?Icons.deselect_rounded:Icons.select_all_rounded),label:Text(allVisibleSelected?'Clear all':'Select all')),FilledButton.icon(onPressed:selected.isEmpty?null:moveSelected,icon:const Icon(Icons.drive_file_move_rounded),label:const Text('Move')),OutlinedButton.icon(onPressed:selected.isEmpty?null:shareSelected,icon:const Icon(Icons.ios_share_rounded),label:const Text('Share')),OutlinedButton.icon(onPressed:selected.isEmpty?null:deleteSelected,icon:const Icon(Icons.delete_outline_rounded,color:Color(0xFFFF6B6B)),label:const Text('Delete',style:TextStyle(color:Color(0xFFFF6B6B)))),OutlinedButton(onPressed:clearSelection,child:const Text('Cancel'))]:[OutlinedButton.icon(onPressed:()=>setState(()=>selectionMode=true),icon:const Icon(Icons.checklist_rounded),label:const Text('Select')),OutlinedButton.icon(onPressed:()=>Process.run('explorer.exe',[widget.project.path]),icon:const Icon(Icons.folder_open_rounded),label:const Text('Open folder'))]);return compact?Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[info,const SizedBox(height:12),actions]):Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:info),const SizedBox(width:16),Flexible(child:Align(alignment:Alignment.topRight,child:actions))]);}),const SizedBox(height:24),LayoutBuilder(builder:(context,c){final compact=c.maxWidth<700;final count=Text('${all.length} footage${all.length==1?'':'s'}',style:const TextStyle(color:Color(0xFF8F96A6)));final searchField=TextField(controller:_projectSearchController,onChanged:(v)=>setState(()=>_projectSearch=v),decoration:InputDecoration(isDense:true,prefixIcon:const Icon(Icons.search_rounded,size:20),hintText:ffTranslate('Search this project...'),suffixIcon:_projectSearch.isEmpty?null:IconButton(tooltip:ffTranslate('Clear'),onPressed:(){_projectSearchController.clear();setState(()=>_projectSearch='');},icon:const Icon(Icons.close_rounded,size:18))));final add=FilledButton.icon(onPressed:addCollection,icon:const Icon(Icons.add_rounded),label:const Text('New collection'));return compact?Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[count,const SizedBox(height:10),searchField,const SizedBox(height:10),Align(alignment:Alignment.centerLeft,child:add)]):Row(children:[count,const SizedBox(width:18),Expanded(child:searchField),const SizedBox(width:18),add]);}),const SizedBox(height:16),Wrap(spacing:10,runSpacing:10,children:[_CollectionChip(label:'All',count:all.length,selected:selectedCollection==null,onTap:()=>setState(()=>selectedCollection=null)),...cols.map((c)=>_CollectionChip(label:c,count:all.where((e)=>e.collection==c).length,selected:selectedCollection==c,onTap:()=>setState(()=>selectedCollection=c),onSecondaryTap:(p)=>collectionMenu(c,p)))]),const SizedBox(height:20),Expanded(child:items.isEmpty?Center(child:Text(selectedCollection==null?'Downloaded footage for this project will appear here.':'No footage in $selectedCollection yet.',style:const TextStyle(color:Color(0xFF858C9C)))):LibraryGrid(items:items,store:widget.libraryStore,projects:widget.projects,selectionMode:selectionMode,selected:selected,onToggle:toggleSelection))])),if(_dropHover)Positioned.fill(child:IgnorePointer(child:Container(decoration:BoxDecoration(color:Theme.of(context).colorScheme.primary.withValues(alpha:.10),border:Border.all(color:Theme.of(context).colorScheme.primary,width:2),borderRadius:BorderRadius.circular(18)),child:Center(child:Container(padding:const EdgeInsets.symmetric(horizontal:24,vertical:18),decoration:BoxDecoration(color:const Color(0xEE151923),borderRadius:BorderRadius.circular(16),border:Border.all(color:Theme.of(context).colorScheme.primary)),child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.file_download_rounded,size:38,color:Theme.of(context).colorScheme.primary),const SizedBox(height:8),Text('Drop files into ${widget.project.name}',style:const TextStyle(fontSize:17,fontWeight:FontWeight.w800)),const SizedBox(height:4),const Text('Video • Audio • Image',style:TextStyle(color:Color(0xFF9AA2B2)))]))))))])); });
}
class _CollectionChip extends StatelessWidget { final String label;final int count;final bool selected;final VoidCallback onTap;final void Function(Offset)? onSecondaryTap;const _CollectionChip({required this.label,required this.count,required this.selected,required this.onTap,this.onSecondaryTap});@override Widget build(BuildContext context)=>GestureDetector(onSecondaryTapDown:onSecondaryTap==null?null:(d)=>onSecondaryTap!(d.globalPosition),child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(20),child:Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:8),decoration:BoxDecoration(color:selected?Theme.of(context).colorScheme.primary.withValues(alpha:.18):const Color(0xFF13161D),border:Border.all(color:selected?Theme.of(context).colorScheme.primary:const Color(0xFF292E3A)),borderRadius:BorderRadius.circular(20)),child:Text('$label  $count',style:TextStyle(fontSize:12,fontWeight:FontWeight.w600,color:selected?Theme.of(context).colorScheme.primary:null))))); }

class StatCard extends StatelessWidget { final IconData icon; final String label; final String value; const StatCard({super.key, required this.icon, required this.label, required this.value}); @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: .14), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Theme.of(context).colorScheme.primary)), const SizedBox(width: 14), Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), Text(label, style: const TextStyle(color: Color(0xFF8F96A6)))])]))); }
class MediaFormat {
  final String id;
  final String label;
  final String ext;
  final int? height;
  final int? filesize;
  final bool hasVideo;
  final bool hasAudio;
  const MediaFormat({required this.id, required this.label, required this.ext, this.height, this.filesize, required this.hasVideo, required this.hasAudio});
}


Future<String?> _refreshHighQualityThumbnail(LibraryItem item, {bool useVideoFrame = false}) async {
  final video = File(item.filePath);
  if (useVideoFrame || (item.sourceUrl ?? '').trim().isEmpty) {
    if (!await video.exists()) throw StateError('The local video file is missing.');
    final ff = DownloaderEngine.ffmpegPath;
    if (ff.isEmpty || !File(ff).existsSync()) throw StateError('FFmpeg is not configured.');
    final base = '${Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path}${Platform.pathSeparator}FootageCollector${Platform.pathSeparator}thumbnails';
    await Directory(base).create(recursive: true);
    final out = '$base${Platform.pathSeparator}${DateTime.now().microsecondsSinceEpoch}_frame.jpg';
    final r = await Process.run(ff, ['-y','-ss','00:00:01','-i',item.filePath,'-frames:v','1','-q:v','2',out]);
    if (r.exitCode != 0 || !await File(out).exists()) throw StateError('Could not extract video frame.');
    return out;
  }
  final media = await DownloaderEngine.analyze(item.sourceUrl!);
  final url = media.thumbnail;
  if (url == null || url.isEmpty) throw StateError('No thumbnail found at source.');
  final cached = await _cacheThumbnailLocally(url);
  if (cached == null) throw StateError('Could not download the source thumbnail.');
  return cached;
}

String? _bestThumbnail(Map<String,dynamic> data) {
  final thumbs=data['thumbnails'];
  if(thumbs is List){
    final candidates=thumbs.whereType<Map>().where((t)=>'${t['url']??''}'.startsWith('http')).toList();
    if(candidates.isNotEmpty){candidates.sort((a,b){
      num score(Map t){final w=(t['width'] as num?)??0;final h=(t['height'] as num?)??0;return w*h;}
      final dimensions=score(b).compareTo(score(a)); if(dimensions!=0)return dimensions; return '${b['id']??''}'.compareTo('${a['id']??''}');
    });return '${candidates.first['url']}';}
  }
  return data['thumbnail'] as String?;
}

class AnalyzedMedia {
  final String id;
  final String title;
  final String? thumbnail;
  final String extractor;
  final List<MediaFormat> formats;
  final double? durationSeconds;
  const AnalyzedMedia({required this.id, required this.title, required this.thumbnail, required this.extractor, required this.formats, this.durationSeconds});
}

class DownloadTask extends ChangeNotifier {
  final String id;
  final String title;
  final String? thumbnail;
  final String projectName;
  final String folder;
  final String formatLabel;
  double progress = 0;
  String speed = '';
  String eta = '';
  String downloaded = '';
  String total = '';
  String status = 'Queued';
  bool done = false;
  bool failed = false;
  bool paused = false;
  bool cancelled = false;
  Process? process;
  String? error;
  final List<String> logLines = [];
  final List<String> outputPaths = [];
  int expectedDownloadParts = 1;
  int currentDownloadPart = 0;
  late String sourceUrl;
  late MediaFormat sourceFormat;
  late AnalyzedMedia sourceMedia;
  ProjectModel? sourceProject;
  String? sourceCollection;
  String outputMode = 'Video + audio';
  String? clipStart;
  String? clipEnd;
  List<ClipRange> clipRanges = [];
  String clipFileMode = 'multi';
  String conflictMode = 'normal';
  DateTime createdAt = DateTime.now();

  Map<String,dynamic> toJson()=>{
    'id':id,'title':title,'thumbnail':thumbnail,'projectName':projectName,'folder':folder,'formatLabel':formatLabel,
    'progress':progress,'status':status,'done':done,'failed':failed,'paused':paused,'cancelled':cancelled,'error':error,
    'sourceUrl':sourceUrl,'logLines':logLines.take(400).toList(),'collection':sourceCollection,'outputMode':outputMode,'clipStart':clipStart,'clipEnd':clipEnd,'clipRanges':clipRanges.map((e)=>e.toJson()).toList(),'clipFileMode':clipFileMode,'conflictMode':conflictMode,'createdAt':createdAt.toIso8601String(),
    'format':{'id':sourceFormat.id,'label':sourceFormat.label,'ext':sourceFormat.ext,'height':sourceFormat.height,'filesize':sourceFormat.filesize,'hasVideo':sourceFormat.hasVideo,'hasAudio':sourceFormat.hasAudio}
  };
  static DownloadTask fromJson(Map<String,dynamic> j){
    final t=DownloadTask(id:'${j['id']}',title:'${j['title']}',thumbnail:j['thumbnail'] as String?,projectName:'${j['projectName']}',folder:'${j['folder']}',formatLabel:'${j['formatLabel']}');
    final f=Map<String,dynamic>.from(j['format'] as Map? ?? const {});
    t.sourceFormat=MediaFormat(id:'${f['id']??''}',label:'${f['label']??''}',ext:'${f['ext']??'mp4'}',height:(f['height'] as num?)?.toInt(),filesize:(f['filesize'] as num?)?.toInt(),hasVideo:f['hasVideo']!=false,hasAudio:f['hasAudio']==true);
    t.sourceUrl='${j['sourceUrl']??''}'; t.logLines.addAll((j['logLines'] as List? ?? const []).map((e)=>'$e')); t.sourceMedia=AnalyzedMedia(id:'',title:t.title,thumbnail:t.thumbnail,extractor:'',formats:[t.sourceFormat]);
    t.sourceCollection=j['collection'] as String?; t.conflictMode='${j['conflictMode']??'normal'}'; t.outputMode='${j['outputMode']??'Video + audio'}'; t.clipStart=j['clipStart'] as String?; t.clipEnd=j['clipEnd'] as String?; t.clipRanges=(j['clipRanges'] as List? ?? const []).map((e)=>ClipRange.fromJson(e)).toList(); t.clipFileMode='${j['clipFileMode']??'multi'}';
    t.progress=(j['progress'] as num?)?.toDouble()??0; t.done=j['done']==true; t.failed=j['failed']==true; t.paused=j['paused']==true; t.cancelled=j['cancelled']==true; t.error=j['error'] as String?; t.status='${j['status']??'Cancelled'}'; t.createdAt=DateTime.tryParse('${j['createdAt']}')??DateTime.now();
    if(!t.done&&!t.failed&&!t.cancelled){t.paused=false;t.cancelled=true;t.status='Interrupted';}
    return t;
  }

  void resetForRetry() { logLines.add('--- RETRY ${DateTime.now().toIso8601String()} ---'); progress = 0; speed = ''; eta = ''; downloaded = ''; total = ''; status = 'Retrying...'; done = false; failed = false; paused = false; cancelled = false; error = null; notifyListeners(); }

  void setStatus(String value) {
    final clean=value.trim();
    if(clean.isNotEmpty){
      logLines.add('[${DateTime.now().toIso8601String()}] $clean');
      if(logLines.length>500) logLines.removeRange(0,logLines.length-500);
      if(clean.startsWith('__FC_FILE__')){ final path=clean.substring('__FC_FILE__'.length).trim(); if(path.isNotEmpty&&!outputPaths.contains(path)) outputPaths.add(path); notifyListeners(); return; }
      final dest=RegExp(r'\[download\] Destination: (.+)$').firstMatch(clean);
      if(dest!=null){final path=dest.group(1)!.trim(); if(path.isNotEmpty&&!outputPaths.contains(path)){outputPaths.add(path); currentDownloadPart=(currentDownloadPart+1).clamp(1,expectedDownloadParts);}}
    }
    if (value.startsWith('FFMPEG_DOWNLOAD|')) {
      final parts = value.split('|');
      final pct = parts.length > 1 ? double.tryParse(parts[1]) : null;
      final detail = parts.length > 2 ? parts[2] : '';
      status = pct == null ? 'Downloading FFmpeg...' : 'Downloading FFmpeg... ${pct.toStringAsFixed(1)}%';
      downloaded = detail;
      progress = pct == null ? 0 : (pct / 100).clamp(0, 1);
    } else if (value == 'FFMPEG_EXTRACT') {
      status = 'Extracting FFmpeg...'; progress = 1; speed = ''; eta = '';
    } else if (value == 'FFMPEG_READY') {
      status = 'FFmpeg ready'; progress = 0; downloaded = '';
    } else if (value.startsWith('Installing FFmpeg')) {
      status = value; progress = 0;
    } else {
      updateFromLine(value); return;
    }
    notifyListeners();
  }

  DownloadTask({required this.id, required this.title, this.thumbnail, required this.projectName, required this.folder, required this.formatLabel});

  void updateFromLine(String line) {
    final m = RegExp(r'\[download\]\s+([\d.]+)%\s+of\s+~?\s*([^ ]+(?:\s*[A-Za-z]+)?)\s+at\s+([^ ]+)\s+ETA\s+([^ ]+)').firstMatch(line);
    final m2 = RegExp(r'\[download\]\s+([\d.]+)%\s+of\s+~?\s*([^ ]+)\s+at\s+([^ ]+)\s+ETA\s+([^ ]+)').firstMatch(line);
    final hit = m ?? m2;
    if (hit != null) {
      final raw=((double.tryParse(hit.group(1) ?? '') ?? 0) / 100).clamp(0.0, 1.0);
      if(expectedDownloadParts>1){ final part=currentDownloadPart==0?1:currentDownloadPart; progress=(((part-1)+raw)/expectedDownloadParts*.92).clamp(0.0,.92); status='Downloading part $part of $expectedDownloadParts'; } else { progress=(raw*.92).clamp(0.0,.92); status='Downloading'; }
      total = hit.group(2) ?? '';
      speed = hit.group(3) ?? '';
      eta = hit.group(4) ?? '';
    } else if (line.contains('[Merger]') || line.contains('[ffmpeg]')) {
      status = 'Merging video & audio...';
      progress = progress < .96 ? .96 : progress;
    } else if (line.contains('[download] 100%')) {
      progress = progress < .92 ? .92 : progress;
      status = 'Finishing...';
    }
    notifyListeners();
  }

  void complete() { process = null; progress = 1; done = true; paused = false; status = 'Completed'; notifyListeners(); }
  void fail(Object e) { process = null; if (paused || cancelled) return; failed = true; if (progress >= 1) progress = 0; error = e.toString().replaceFirst('Exception: ', ''); status = 'Failed'; notifyListeners(); }
  void markPaused() { paused = true; status = 'Paused'; speed = ''; eta = ''; notifyListeners(); }
  void markCancelled() { cancelled = true; paused = false; failed = false; done = false; status = 'Cancelled'; speed = ''; eta = ''; notifyListeners(); }
}

class DownloadManager extends ChangeNotifier {
  final LibraryStore libraryStore;
  DownloadManager(this.libraryStore);
  static const _historyKey='footage_collector_download_history_v1';
  final List<DownloadTask> tasks = [];
  Future<void> loadHistory() async {
    try{final p=await SharedPreferences.getInstance();final raw=p.getString(_historyKey);if(raw!=null){tasks.addAll((jsonDecode(raw) as List).map((e)=>DownloadTask.fromJson(Map<String,dynamic>.from(e))));}}catch(_){}
    notifyListeners();
  }
  Future<void> _saveHistory() async {final p=await SharedPreferences.getInstance();await p.setString(_historyKey,jsonEncode(tasks.take(200).map((e)=>e.toJson()).toList()));}
  int get activeCount => tasks.where((t) => !t.done && !t.failed && !t.paused && !t.cancelled).length;

  Future<String> _defaultDownloadsFolder() async {
    final custom = await AppSettingsStore.loadDefaultDownloadPath();
    if (custom != null && custom.isNotEmpty) return custom;
    final userProfile = Platform.environment['USERPROFILE'];
    final base = (userProfile != null && userProfile.isNotEmpty)
        ? '$userProfile${Platform.pathSeparator}Downloads'
        : Directory.current.path;
    return '$base${Platform.pathSeparator}Footage Collector';
  }

  Future<void> start({required String url, required MediaFormat format, required AnalyzedMedia media, ProjectModel? project, String? collection, String outputMode = 'Video + audio', String? clipStart, String? clipEnd, List<ClipRange> clipRanges = const [], String clipFileMode = 'multi', String conflictMode = 'normal'}) async {
    final folder = project != null ? '${project.path}${Platform.pathSeparator}Downloads' : await _defaultDownloadsFolder();
    final task = DownloadTask(
      id: DateTime.now().microsecondsSinceEpoch.toString(), title: media.title, thumbnail: media.thumbnail,
      projectName: project?.name ?? 'Windows Downloads', folder: folder, formatLabel: '${format.label} • ${format.ext.toUpperCase()}',
    );
    task.sourceUrl = url; task.sourceFormat = format; task.expectedDownloadParts=(outputMode=='Video + audio' && format.hasVideo && !format.hasAudio)?2:1; task.sourceMedia = media; task.sourceProject = project; task.sourceCollection = collection; task.outputMode = outputMode; task.clipStart = clipStart; task.clipEnd = clipEnd; task.clipRanges = clipRanges; task.clipFileMode = clipFileMode; task.conflictMode=conflictMode;
    tasks.insert(0, task); await _saveHistory(); notifyListeners();
    await _run(task);
  }

  Future<void> _run(DownloadTask task) async {
    try {
      if(task.conflictMode=='replace'){
        final mediaId=task.sourceMedia.id;
        if(mediaId.isNotEmpty){
          final dir=Directory(task.folder);
          if(await dir.exists()){
            await for(final e in dir.list()){
              if(e is File && e.path.contains('[$mediaId]')){try{await e.delete();}catch(_){}}
            }
          }
        }
      }
      await DownloaderEngine.download(url: task.sourceUrl, format: task.sourceFormat, folder: task.folder, outputMode: task.outputMode, clipStart: task.clipStart, clipEnd: task.clipEnd, clipRanges: task.clipRanges, clipFileMode: task.clipFileMode, conflictMode: task.conflictMode, onLine: task.setStatus, onProcess: (p) => task.process = p);
      if (!task.paused && !task.cancelled) {
        task.complete();
        await _registerCompleted(task);
        if(task.clipRanges.length>1){
          final dir=Directory(task.folder);
          if(await dir.exists()){
            await for(final entity in dir.list()){
              if(entity is! File)continue;
              final path=entity.path.toLowerCase();
              if(!(path.endsWith('.part') || path.endsWith('.ytdl')))continue;
              try{
                final modified=await entity.lastModified();
                if(!modified.isBefore(task.createdAt))await entity.delete();
              }catch(_){}
            }
          }
        }
      }
    } catch (e) {
      task.fail(e);
    }
    await _saveHistory(); notifyListeners();
  }

  Future<void> _registerCompleted(DownloadTask task) async {
    try {
      final dir=Directory(task.folder); if(!await dir.exists())return;
      final files=<File>[];
      for(final path in task.outputPaths){final f=File(path);if(await f.exists())files.add(f);}
      if(files.isEmpty){await for(final e in dir.list()){if(e is File&&!e.path.endsWith('.part')&&!e.path.endsWith('.ytdl')&&e.lastModifiedSync().isAfter(task.createdAt.subtract(const Duration(seconds:2))))files.add(e);}}
      if(files.isEmpty)return;
      // The output markers are the authoritative result set. Do not include
      // temporary files or unrelated downloads in the same destination folder.
      if(task.clipRanges.length>1 && task.clipFileMode=='multi') {
        final expected=task.outputPaths.where((path)=>File(path).existsSync()).toSet();
        files.removeWhere((file)=>!expected.contains(file.path));
      }
      files.sort((a,b)=>a.path.compareTo(b.path));
      var clipIndex=0;
      for(final f in (task.clipRanges.length>1 && task.clipFileMode=='multi' ? files : <File>[files.first])) {
      clipIndex++;

      final size=await f.length();
      final ext=f.path.split('.').last.toLowerCase();
      const audioExt={'mp3','m4a','aac','wav','flac','ogg','opus','wma'};
      const imageExt={'jpg','jpeg','png','webp','gif','bmp','tif','tiff'};
      final actualType=audioExt.contains(ext)?'Audio':imageExt.contains(ext)?'Image':'Video';
      final actualFormat='$actualType • ${ext.toUpperCase()}';
      final localThumb=actualType=='Video'?await _cacheThumbnailLocally(task.thumbnail,videoPath:f.path):await _cacheThumbnailLocally(task.thumbnail);
      final item=LibraryItem(id:'${DateTime.now().microsecondsSinceEpoch}',title:task.clipRanges.length>1 ? f.path.split(Platform.pathSeparator).last.replaceFirst(RegExp(r'\.[^.]+$'),'') : task.title,filePath:f.path,projectId:task.sourceProject?.id??'',projectName:task.sourceProject?.name??'Windows Downloads',formatLabel:actualFormat,thumbnail:localThumb,collection:task.sourceCollection,sourceUrl:task.sourceUrl,outputMode:task.outputMode,clipStart:task.clipStart,clipEnd:task.clipEnd,sizeBytes:size,addedAt:DateTime.now());
      if(task.conflictMode=='replace' && !(task.clipRanges.length>1 && task.clipFileMode=='multi')) await libraryStore.replaceDownloadedItem(item,sourceUrl:task.sourceUrl); else await libraryStore.addItem(item);
      }
    } catch(_) {}
  }

  Future<void> retry(DownloadTask task) async {
    if (!task.failed) return;
    task.resetForRetry(); await _saveHistory(); notifyListeners();
    await _run(task);
  }

  Future<void> pause(DownloadTask task) async {
    if (task.done || task.failed || task.paused || task.cancelled) return;
    task.markPaused();
    task.process?.kill();
    task.process = null;
    await _saveHistory(); notifyListeners();
  }

  Future<void> resume(DownloadTask task) async {
    if (!task.paused || task.cancelled) return;
    task.paused = false; task.status = 'Resuming...'; task.notifyListeners(); await _saveHistory(); notifyListeners();
    await _run(task);
  }

  Future<void> cancel(DownloadTask task) async {
    if (task.done || task.cancelled) return;
    task.markCancelled();
    task.process?.kill(); task.process = null;
    try {
      final dir = Directory(task.folder);
      if (await dir.exists()) {
        await for (final e in dir.list()) {
          if (e is File && (e.path.endsWith('.part') || e.path.endsWith('.ytdl') || e.path.endsWith('.temp'))) { try { await e.delete(); } catch (_) {} }
        }
        for(final path in task.outputPaths){ try{final f=File(path); if(await f.exists()) await f.delete();}catch(_){}}
      }
    } catch (_) {}
    await _saveHistory(); notifyListeners();
  }

  Future<void> removeFromHistory(Iterable<DownloadTask> selected) async {
    final ids=selected.map((e)=>e.id).toSet();
    tasks.removeWhere((t)=>ids.contains(t.id));
    await _saveHistory(); notifyListeners();
  }

  Future<void> redownload(DownloadTask old,{ProjectModel? project,String? collection}) async {
    await start(url:old.sourceUrl,format:old.sourceFormat,media:old.sourceMedia,project:project,collection:collection,outputMode:old.outputMode,clipStart:old.clipStart,clipEnd:old.clipEnd,clipRanges:old.clipRanges,clipFileMode:old.clipFileMode,conflictMode:'normal');
  }
}

class DownloaderEngine {
  static String? configuredFfmpegPath;
  static String? configuredYtDlpPath;

  static String get ytDlpPath => configuredYtDlpPath ?? '';
  static String get ffmpegPath => configuredFfmpegPath ?? '';
  static String get ffprobePath {
    final ff = configuredFfmpegPath;
    if (ff == null || ff.isEmpty) return '';
    return '${File(ff).parent.path}${Platform.pathSeparator}ffprobe.exe';
  }

  static Future<bool> validateFfmpeg(String path) async {
    try {
      final f = File(path);
      if (!await f.exists()) return false;
      final r = await Process.run(path, ['-version']);
      return r.exitCode == 0 && '${r.stdout}'.toLowerCase().contains('ffmpeg');
    } catch (_) { return false; }
  }


  static Future<bool> validateYtDlp(String path) async {
    try {
      final f = File(path);
      if (!await f.exists()) return false;
      final r = await Process.run(path, ['--version']);
      return r.exitCode == 0 && '${r.stdout}'.trim().isNotEmpty;
    } catch (_) { return false; }
  }

  static Future<void> ensureYtDlp({void Function(String)? status}) async {
    final path = configuredYtDlpPath;
    if (path == null || path.isEmpty || !await validateYtDlp(path)) {
      throw Exception('yt-dlp is not configured. Open Settings and choose yt-dlp.exe.');
    }
    status?.call('YTDLP_READY');
  }

  static Future<void> ensureFfmpeg({void Function(String)? status}) async {
    final path = configuredFfmpegPath;
    if (path == null || path.isEmpty || !await validateFfmpeg(path)) {
      throw Exception('FFmpeg is not configured. Open Settings and choose ffmpeg.exe.');
    }
    status?.call('FFMPEG_READY');
  }


  static Future<AnalyzedMedia> analyze(String url, {void Function(String)? status}) async {
    await ensureYtDlp(status: status);
    final uri=Uri.tryParse(url);
    final host=(uri?.host??'').toLowerCase();
    final social=host.contains('tiktok.com')||host.contains('instagram.com');
    final proxyMode=await AppSettingsStore.loadProxyMode();
    final proxyUrl=await AppSettingsStore.loadProxyUrl();
    final baseArgs=<String>['--no-playlist','--dump-single-json','--no-warnings','--socket-timeout',social?'45':'30','--retries',social?'3':'2','--extractor-retries',social?'3':'2'];
    if(proxyMode=='custom'&&proxyUrl!=null){baseArgs.addAll(['--proxy',proxyUrl]);status?.call('Analyze proxy: custom');}
    else if(proxyMode=='off'){baseArgs.addAll(['--proxy','']);status?.call('Analyze proxy: off');}
    Map<String,String>? env;
    if(proxyMode=='custom'&&proxyUrl!=null){env=Map<String,String>.from(Platform.environment);for(final k in ['HTTP_PROXY','HTTPS_PROXY','http_proxy','https_proxy','ALL_PROXY','all_proxy']){env[k]=proxyUrl;}}
    else if(proxyMode=='off'){env=Map<String,String>.from(Platform.environment);for(final k in ['HTTP_PROXY','HTTPS_PROXY','http_proxy','https_proxy','ALL_PROXY','all_proxy']){env.remove(k);}}
    final isYoutube=host.contains('youtube.com')||host.contains('youtu.be');
    if(isYoutube){
      final authMode=await AppSettingsStore.loadYoutubeAuthMode();
      if(authMode=='browser'){ final browser=await AppSettingsStore.loadYoutubeBrowser(); baseArgs.addAll(['--cookies-from-browser',browser]); status?.call('YouTube authentication: $browser browser cookies'); }
      else if(authMode=='file'){ final cookieFile=await AppSettingsStore.loadYoutubeCookiesFile(); if(cookieFile!=null&&File(cookieFile).existsSync()){baseArgs.addAll(['--cookies',cookieFile]);status?.call('YouTube authentication: cookies.txt');} }
    }
    ProcessResult? result;
    final attempts=social?3:1;
    for(var i=1;i<=attempts;i++){
      status?.call(social?'Analyzing ${host.contains('tiktok')?'TikTok':'Instagram'}...${i>1?' retry $i/$attempts':''}':'Analyzing link...');
      result=await Process.run(ytDlpPath,[...baseArgs,url],environment:env);
      if(result.exitCode==0)break;
    }
    if (result==null||result.exitCode != 0) throw Exception(result==null?'Could not analyze this link.':('${result.stderr}').trim().isEmpty ? 'Could not analyze this link.' : ('${result.stderr}').trim());
    final data = jsonDecode(result.stdout as String) as Map<String, dynamic>;
    final raw = (data['formats'] as List? ?? const []);
    final formats = <MediaFormat>[]; final seen = <String>{};
    for (final item in raw) {
      final f = Map<String, dynamic>.from(item as Map); final id = '${f['format_id'] ?? ''}'; if (id.isEmpty) continue;
      final vcodec = '${f['vcodec'] ?? 'none'}'; final acodec = '${f['acodec'] ?? 'none'}';
      var hasVideo = vcodec != 'none'; var hasAudio = acodec != 'none';
      if (!hasVideo && !hasAudio) {
        final formatUrl = f['url'];
        final extHint = '${f['ext'] ?? ''}'.toLowerCase();
        final direct = formatUrl is String ? Uri.tryParse(formatUrl) : null;
        if (direct != null && (direct.scheme == 'https' || direct.scheme == 'http') &&
            const ['mp4', 'webm', 'mov', 'm4v'].contains(extHint)) {
          hasVideo = true; hasAudio = true;
        } else { continue; }
      }
      final height = (f['height'] as num?)?.toInt(); final ext = '${f['ext'] ?? ''}'; final size = ((f['filesize'] ?? f['filesize_approx']) as num?)?.toInt();
      String label;
      if (hasVideo) { label = height != null ? '${height}p' : '${f['format_note'] ?? 'Video'}'; label += hasAudio ? ' • video + audio' : ' • video'; }
      else { label = 'Audio • ${f['abr'] != null ? '${(f['abr'] as num).round()} kbps' : ext.toUpperCase()}'; }
      final key = '$label|$ext|$hasAudio'; if (!seen.add(key)) continue;
      formats.add(MediaFormat(id: id, label: label, ext: ext, height: height, filesize: size, hasVideo: hasVideo, hasAudio: hasAudio));
    }
    // yt-dlp generic/direct-file extractors can return a single top-level media
    // object without a `formats` array. Do not interpret that as no download.
    if (formats.isEmpty) {
      final directUrl = data['url'];
      final protocol = '${data['protocol'] ?? ''}'.toLowerCase();
      final ext = '${data['ext'] ?? ''}'.toLowerCase();
      final parsedDirect = directUrl is String ? Uri.tryParse(directUrl) : null;
      final isHttp = parsedDirect != null &&
          (parsedDirect.scheme == 'http' || parsedDirect.scheme == 'https');
      final isMedia = const ['mp4', 'webm', 'mov', 'm4v', 'mkv', 'mp3', 'm4a', 'aac', 'ogg', 'opus'].contains(ext);
      final isStream = const ['m3u8', 'm3u8_native', 'http_dash_segments'].contains(protocol);
      if (isHttp && (isMedia || isStream)) {
        final isAudio = const ['mp3', 'm4a', 'aac', 'ogg', 'opus'].contains(ext);
        final height = (data['height'] as num?)?.toInt();
        final filesize = ((data['filesize'] ?? data['filesize_approx']) as num?)?.toInt();
        formats.add(MediaFormat(
          id: 'best',
          label: isAudio ? 'Original audio' :
              (height != null ? 'Original quality • ${height}p' : 'Original quality'),
          ext: ext.isEmpty ? (isStream ? 'mp4' : 'bin') : ext,
          height: height,
          filesize: filesize,
          hasVideo: !isAudio,
          hasAudio: true,
        ));
      }
    }
    formats.sort((a,b) { if (a.hasVideo != b.hasVideo) return a.hasVideo ? -1 : 1; return (b.height ?? 0).compareTo(a.height ?? 0); });
    return AnalyzedMedia(id: '${data['id'] ?? ''}', title: '${data['title'] ?? 'Untitled'}', thumbnail: _bestThumbnail(data), extractor: '${data['extractor_key'] ?? data['extractor'] ?? 'Website'}', formats: formats, durationSeconds: (data['duration'] as num?)?.toDouble());
  }

  static Future<void> download({required String url, required MediaFormat format, required String folder, required void Function(String) onLine, void Function(Process)? onProcess, String outputMode = 'Video + audio', String? clipStart, String? clipEnd, List<ClipRange> clipRanges = const [], String clipFileMode = 'multi', String conflictMode = 'normal'}) async {
    await ensureYtDlp(status: onLine); await Directory(folder).create(recursive: true);
    if(clipRanges.length>1){
      final outputs=<String>[];
      final stamp=DateTime.now().microsecondsSinceEpoch;
      for(var i=0;i<clipRanges.length;i++){
        final part=clipRanges[i];
        onLine('Clip ${i+1}/${clipRanges.length}: ${part.start} → ${part.end}');
        final captured=<String>[];
        await download(url:url,format:format,folder:folder,outputMode:outputMode,
          clipStart:part.start,clipEnd:part.end,conflictMode:'rename',
          onProcess:onProcess,onLine:(line){
            if(line.startsWith('__FC_FILE__')){
              final path=line.substring('__FC_FILE__'.length).trim();
              if(path.isNotEmpty)captured.add(path);
              // Emit final paths only after the file has been renamed below.
            }else{onLine(line);}
          });
        if(captured.isEmpty)throw StateError('Clip ${i+1} produced no output file.');
        var path=captured.last;
        if(clipFileMode=='multi'){
          final original=File(path);
          final extension=path.contains('.')?path.substring(path.lastIndexOf('.')):'';
          final stem=path.substring(0,path.length-extension.length);
          final base=stem.split(Platform.pathSeparator).last;
          final marker=RegExp(r'\s*\[[^\]]+\]');
          final cleanBase=base.replaceAll(marker,'').replaceAll(RegExp(r'\.f\d+.*$'),'').trim();
          final suffix=part.name.trim().isNotEmpty?part.name.trim():'${part.start} to ${part.end}';
          final safeSuffix=suffix.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'),'_').trim();
          final candidateStem='${original.parent.path}${Platform.pathSeparator}$cleanBase - $safeSuffix';
          var candidate='$candidateStem$extension';
          var counter=2;
          while(File(candidate).existsSync() && candidate!=path){candidate='$candidateStem ($counter)$extension';counter++;}
          if(candidate!=path){await original.rename(candidate);path=candidate;}
          onLine('__FC_FILE__$path');
        }
        outputs.add(path);
      }
      if(clipFileMode=='single'){
        await ensureFfmpeg(status:onLine);
        final ext=outputs.first.split('.').last.toLowerCase();
        final safeExt=({'mp4','mkv','webm','mov'}.contains(ext))?ext:'mkv';
        final firstName=outputs.first.split(Platform.pathSeparator).last;
         final firstStem=firstName.contains('.')?firstName.substring(0,firstName.lastIndexOf('.')):firstName;
         final cleaned=firstStem.replaceAll(RegExp(r'\.f\d+.*$'),'').replaceAll(RegExp(r'\s*\[[^\]]+\]'),'').trim();
         final output='${folder}${Platform.pathSeparator}$cleaned - Combined_$stamp.$safeExt';
        final listFile=File('${Directory.systemTemp.path}${Platform.pathSeparator}ff_concat_$stamp.txt');
        try{
          // The segments originate from one source and normally share codecs.
          await listFile.writeAsString(outputs.map((e)=>"file '${e.replaceAll('\\','/').replaceAll("'", "'\\''")}'").join('\n'));
          final proc=await Process.start(ffmpegPath,['-hide_banner','-y','-f','concat','-safe','0','-i',listFile.path,'-c','copy',output],runInShell:false);
          onProcess?.call(proc);
          final stderr=proc.stderr.transform(const Utf8Decoder(allowMalformed:true)).transform(const LineSplitter()).listen(onLine).asFuture<void>();
          final stdout=proc.stdout.drain<void>();
          final code=await proc.exitCode; await Future.wait([stderr,stdout]);
          if(code!=0)throw StateError('FFmpeg could not combine the clips (exit $code).');
          for(final path in outputs){try{await File(path).delete();}catch(_){}}
          onLine('__FC_FILE__$output');
        }finally{if(await listFile.exists())await listFile.delete();}
      }
      return;
    }
    var selector = format.id;
    final args = ['--no-playlist', '--newline', '--progress', '--verbose', '--windows-filenames', '--encoding','utf-8', '--socket-timeout','45','--retries','3','--fragment-retries','3','--extractor-retries','3','--print', 'after_move:__FC_FILE__%(filepath)s'];
    if(conflictMode=='replace') args.add('--force-overwrites');
    final isClip = clipStart != null && clipEnd != null;
    if (isClip || outputMode == 'Audio only' || outputMode == 'Edit-friendly MP4 (H.264)' || (outputMode == 'Video + audio' && format.hasVideo && !format.hasAudio)) {
      await ensureFfmpeg(status: onLine);
      args.addAll(['--ffmpeg-location', ffmpegPath]);
    }
    if (isClip) {
      // Do not use --force-keyframes-at-cuts here. It forces FFmpeg to re-encode
      // the selected section, which can consume huge CPU/RAM on long/4K sources.
      // yt-dlp + FFmpeg will instead copy the requested section around keyframes.
      onLine('Clip mode: $clipStart → $clipEnd (fast stream-copy around keyframes)');
      args.addAll(['--download-sections', '*$clipStart-$clipEnd']);
    }
    if (outputMode == 'Edit-friendly MP4 (H.264)') {
      selector = format.hasVideo && !format.hasAudio ? '${format.id}+bestaudio/best' : format.id;
      args.addAll(['--merge-output-format','mp4','--recode-video','mp4','--postprocessor-args','VideoConvertor+ffmpeg_o:-c:v libx264 -preset fast -crf 18 -c:a aac -b:a 192k']);
      onLine('Output: edit-friendly MP4 / H.264 + AAC');
    } else if (outputMode == 'Audio only') {
      selector = 'bestaudio/best';
      args.addAll(['-x', '--audio-format', 'mp3']);
    } else if (outputMode == 'Video only') {
      selector = format.hasVideo ? format.id : 'bestvideo';
    } else if (format.hasVideo && !format.hasAudio) {
      selector = '${format.id}+bestaudio/best';
      // Keep the selected container where possible. Forcing WEBM video into MP4 can
      // make FFmpeg do extra work or fail depending on the selected codecs.
      final mergeExt = format.ext.toLowerCase() == 'webm' ? 'webm' : 'mp4';
      args.addAll(['--merge-output-format', mergeExt]);
    }
    if (isClip && outputMode == 'Video + audio' && format.hasVideo && !format.hasAudio) {
      // yt-dlp section downloads use FFmpeg as an external downloader. When
      // selecting separate video+audio streams, FFmpeg's section handling can
      // silently produce video-only fragments. Prefer a muxed A/V source for
      // clip extraction; retain separate-stream fallback where unavailable.
      selector = 'best[acodec!=none][vcodec!=none]/${format.id}+bestaudio/best';
      onLine('Clip audio: prefer a source containing both video and audio.');
    }
    final downloadUri=Uri.tryParse(url);
    final downloadHost=(downloadUri?.host??'').toLowerCase();
    final isYoutube=downloadHost.contains('youtube.com')||downloadHost.contains('youtu.be');
    if(isYoutube){
      final authMode=await AppSettingsStore.loadYoutubeAuthMode();
      if(authMode=='browser'){ final browser=await AppSettingsStore.loadYoutubeBrowser(); args.addAll(['--cookies-from-browser',browser]); onLine('YouTube authentication: $browser browser cookies'); }
      else if(authMode=='file'){ final cookieFile=await AppSettingsStore.loadYoutubeCookiesFile(); if(cookieFile!=null&&File(cookieFile).existsSync()){args.addAll(['--cookies',cookieFile]);onLine('YouTube authentication: cookies.txt');} else {onLine('WARNING: YouTube cookies file is missing.');} }
    }
    final proxyMode = await AppSettingsStore.loadProxyMode();
    final proxyUrl = await AppSettingsStore.loadProxyUrl();
    if (proxyMode == 'custom' && proxyUrl != null) {
      args.addAll(['--proxy', proxyUrl]);
      onLine('Proxy: custom (${proxyUrl.replaceAll(RegExp(r'//.*@'), '//***@')})');
    } else if (proxyMode == 'off') {
      args.addAll(['--proxy', '']);
      onLine('Proxy: off');
    } else {
      onLine('Proxy: system / environment');
    }
    final suffix = isClip ? ' [clip $clipStart-$clipEnd]' : '';
    final renameTag = conflictMode=='rename' ? ' [${DateTime.now().millisecondsSinceEpoch}]' : '';
    args.addAll(['-f', selector, '-o', '$folder${Platform.pathSeparator}%(title).180B$suffix [%(id)s]$renameTag.%(ext)s', url]);
    onLine('yt-dlp executable: $ytDlpPath');
    onLine('FFmpeg executable: ${ffmpegPath.isEmpty ? '(not required)' : ffmpegPath}');
    final safeArgs = args.isNotEmpty ? [...args.sublist(0, args.length - 1), '<SOURCE_URL>'] : args;
    onLine('yt-dlp args: ${safeArgs.join(' ')}');
    Map<String,String>? processEnv;
    if (proxyMode == 'custom' && proxyUrl != null) {
      processEnv = Map<String,String>.from(Platform.environment);
      processEnv['HTTP_PROXY'] = proxyUrl; processEnv['HTTPS_PROXY'] = proxyUrl;
      processEnv['http_proxy'] = proxyUrl; processEnv['https_proxy'] = proxyUrl;
      processEnv['ALL_PROXY'] = proxyUrl; processEnv['all_proxy'] = proxyUrl;
    } else if (proxyMode == 'off') {
      processEnv = Map<String,String>.from(Platform.environment)
        ..remove('HTTP_PROXY')..remove('HTTPS_PROXY')..remove('http_proxy')..remove('https_proxy')..remove('ALL_PROXY')..remove('all_proxy');
    }
    final process = await Process.start(ytDlpPath, args, runInShell: false, environment: processEnv);
    onProcess?.call(process);
    final errors = <String>[];
    // yt-dlp can inherit a Windows legacy code page (for example cp1252).
    // Force UTF-8 above, and keep the stream decoder tolerant so a single
    // malformed metadata/title byte can never abort an otherwise valid download.
    final safeUtf8 = const Utf8Decoder(allowMalformed: true);
    final outDone = process.stdout.transform(safeUtf8).transform(const LineSplitter()).listen(onLine).asFuture<void>();
    final errDone = process.stderr.transform(safeUtf8).transform(const LineSplitter()).listen((line) {
      onLine(line);
      final t = line.trim();
      if (t.isNotEmpty) { errors.add(t); if (errors.length > 12) errors.removeAt(0); }
    }).asFuture<void>();
    final code = await process.exitCode;
    await Future.wait([outDone, errDone]);
    if (code != 0) {
      final useful = errors.reversed.firstWhere(
        (e) => e.toLowerCase().contains('error') || e.toLowerCase().contains('failed'),
        orElse: () => errors.isEmpty ? '' : errors.last,
      );
      throw Exception(useful.isEmpty ? 'Download failed (code $code).' : useful);
    }
  }
}

class ClipRange {
  final String start, end, name;
  const ClipRange(this.start, this.end, [this.name = '']);
  Map<String,dynamic> toJson()=>{'start':start,'end':end,'name':name};
  static ClipRange fromJson(dynamic j)=>ClipRange('${j['start']??''}','${j['end']??''}','${j['name']??''}');
}

class ClipRangeEditor {
  final TextEditingController start, end, name;
  ClipRangeEditor([String a='00:00:00',String b='00:00:10']):start=TextEditingController(text:a),end=TextEditingController(text:b),name=TextEditingController();
  void dispose(){start.dispose();end.dispose();name.dispose();}
}

class UniversalDownloaderPage extends StatefulWidget {
  final List<ProjectModel> projects; final DownloadManager downloadManager;
  const UniversalDownloaderPage({super.key, required this.projects, required this.downloadManager});
  @override State<UniversalDownloaderPage> createState() => _UniversalDownloaderPageState();
}

class _UniversalDownloaderPageState extends State<UniversalDownloaderPage> {
  final controller = TextEditingController(); bool analyzing = false; String status = 'Paste a public media link to begin.';
  AnalyzedMedia? media; ProjectModel? project; MediaFormat? selected;
  String? collection;
  bool clipMode = false; String outputMode = 'Video + audio';
  bool get _isDirectOriginal => media != null && media!.formats.length == 1 && media!.formats.first.label.startsWith('Original');
  final clipStartController = TextEditingController(text: '00:00:00');
  final clipEndController = TextEditingController(text: '00:00:10');
  final clipNameController = TextEditingController();
  final List<ClipRangeEditor> extraClips=[];
  String clipFileMode='multi';
  void _refreshClipValidation(){if(mounted)setState((){});}
  @override void initState() { super.initState(); clipStartController.addListener(_refreshClipValidation); clipEndController.addListener(_refreshClipValidation); _restoreRecentProject(); FootageFlowChromeBridge.incomingUrl.addListener(_acceptChromeUrl); WidgetsBinding.instance.addPostFrameCallback((_) => _acceptChromeUrl()); }
  void _acceptChromeUrl() { final url = FootageFlowChromeBridge.incomingUrl.value; if (!mounted || url == null) return; FootageFlowChromeBridge.incomingUrl.value = null; controller.text = url; if (!analyzing) { analyze(); } else { _pendingChromeUrl = url; } }
  String? _pendingChromeUrl;
  Future<void> _restoreRecentProject() async {
    final id = await AppSettingsStore.loadRecentProject();
    if (!mounted || id == null) return;
    ProjectModel? found;
    for (final p in widget.projects) { if (p.id == id) { found = p; break; } }
    if (found != null) setState(() { project = found; collection = null; });
  }
  Future<void> _selectProject(ProjectModel? value) async {
    setState(() { project = value; collection = null; });
    await AppSettingsStore.saveRecentProject(value?.id);
  }
  @override void dispose() { FootageFlowChromeBridge.incomingUrl.removeListener(_acceptChromeUrl); controller.dispose(); clipStartController.removeListener(_refreshClipValidation); clipEndController.removeListener(_refreshClipValidation); clipStartController.dispose(); clipEndController.dispose(); clipNameController.dispose(); for(final e in extraClips){e.dispose();} super.dispose(); }

  Future<void> analyze() async {
    final url = controller.text.trim(); final uri = Uri.tryParse(url);
    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) { setState(() => status = 'Enter a valid http/https link.'); return; }
    setState(() { analyzing = true; media = null; selected = null; status = 'Preparing...'; });
    try {
      final result = await DownloaderEngine.analyze(url, status: (s) { if (mounted) setState(() => status = s); });
      if (!mounted) return;
      setState(() { media = result; selected = result.formats.where((f) => f.hasVideo && f.hasAudio).firstOrNull ?? result.formats.firstOrNull; status = '${result.formats.length} formats found.'; });
    } catch (e) { if (mounted) setState(() => status = e.toString().replaceFirst('Exception: ', '')); }
    finally { if (mounted) { setState(() => analyzing = false); final pending = _pendingChromeUrl; _pendingChromeUrl = null; if (pending != null) { controller.text = pending; analyze(); } } }
  }

  int? _timeToSeconds(String value) {
    final parts = value.trim().split(':'); if (parts.isEmpty || parts.length > 3) return null;
    final nums = parts.map(int.tryParse).toList(); if (nums.any((e) => e == null)) return null;
    if (parts.length >= 2 && (nums.last! > 59 || nums[nums.length-2]! > 59)) return null;
    if (parts.length == 3) return nums[0]! * 3600 + nums[1]! * 60 + nums[2]!;
    if (parts.length == 2) return nums[0]! * 60 + nums[1]!;
    return nums[0]!;
  }

  String _formatDuration(double seconds) {
    final t=seconds.floor();
    return '${(t ~/ 3600).toString().padLeft(2,'0')}:${((t ~/ 60)%60).toString().padLeft(2,'0')}:${(t%60).toString().padLeft(2,'0')}';
  }
  String? get _clipValidation {
    if(!clipMode || media==null)return null;
    final pairs=<List<String>>[[clipStartController.text,clipEndController.text],...extraClips.map((e)=>[e.start.text,e.end.text])];
    for(var i=0;i<pairs.length;i++){
      final a=_timeToSeconds(pairs[i][0]),b=_timeToSeconds(pairs[i][1]);
      if(a==null||b==null||a<0||b<=a)return 'Clip ${i+1}: invalid start/end time.';
      final duration=media!.durationSeconds;
      if(duration!=null && b>duration+0.25)return 'Clip ${i+1}: end exceeds video duration (${_formatDuration(duration)}).';
    }
    return null;
  }

  Future<void> download() async {
    final f = selected; final p = project; final m = media; if (m == null || f == null) return;
    final invalid=_clipValidation; if(invalid!=null){setState(()=>status=invalid);return;}
    String? start, end;
    final ranges=<ClipRange>[];
    if (clipMode) {
      start = clipStartController.text.trim(); end = clipEndController.text.trim();
      final a = _timeToSeconds(start), b = _timeToSeconds(end);
      if (a == null || b == null || b <= a) { setState(() => status = 'Clip time is invalid. Use HH:MM:SS and make End later than Start.'); return; }
      if (m.durationSeconds != null && b > m.durationSeconds! + 0.25) { setState(() => status = 'Clip 1 exceeds video duration (${_formatDuration(m.durationSeconds!)}).'); return; }
       ranges.add(ClipRange(start,end,clipNameController.text.trim()));
      for(final e in extraClips){final x=e.start.text.trim(),y=e.end.text.trim();final a=_timeToSeconds(x),b=_timeToSeconds(y);if(a==null||b==null||b<=a){setState(()=>status='Invalid clip range. End must be later than Start.');return;}if(m.durationSeconds!=null && b>m.durationSeconds!+0.25){setState(()=>status='Clip ${ranges.length+1} exceeds video duration (${_formatDuration(m.durationSeconds!)}).');return;}ranges.add(ClipRange(x,y,e.name.text.trim()));}
    }
    final url = controller.text.trim();
    var conflictMode='normal';
    final folder=p!=null?'${p.path}${Platform.pathSeparator}Downloads':await widget.downloadManager._defaultDownloadsFolder();
    if(m.id.isNotEmpty && Directory(folder).existsSync()){
      final exists=Directory(folder).listSync().whereType<File>().any((e)=>e.path.contains('[${m.id}]'));
      if(exists && mounted){
        final choice=await showDialog<String>(context:context,builder:(d)=>AlertDialog(title:const Text('File already exists'),content:Text('A download of "${m.title}" already exists in this folder. What should Footage Collector do?'),actions:[TextButton(onPressed:()=>Navigator.pop(d,'cancel'),child:const Text('Cancel')),TextButton(onPressed:()=>Navigator.pop(d,'rename'),child:const Text('Keep both')),FilledButton(onPressed:()=>Navigator.pop(d,'replace'),child:const Text('Replace'))]));
        if(choice==null||choice=='cancel')return; conflictMode=choice;
      }
    }
    await widget.downloadManager.start(url: url, format: f, media: m, project: p, collection: collection, outputMode: _isDirectOriginal ? 'Video + audio' : outputMode, clipStart: start, clipEnd: end, clipRanges: ranges.length>1?ranges:const [], clipFileMode:clipFileMode, conflictMode: conflictMode);
  }

  String sizeText(int? bytes) { if (bytes == null) return ''; if (bytes > 1024*1024*1024) return '${(bytes/(1024*1024*1024)).toStringAsFixed(1)} GB'; if (bytes > 1024*1024) return '${(bytes/(1024*1024)).toStringAsFixed(1)} MB'; return '${(bytes/1024).toStringAsFixed(0)} KB'; }

  @override Widget build(BuildContext context) => AnimatedBuilder(animation: widget.downloadManager, builder: (context, _) {
    final active = widget.downloadManager.tasks.where((t) => !t.done && !t.failed && !t.paused && !t.cancelled).toList();
    return Padding(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Universal Downloader', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)), const SizedBox(height: 6),

      const Text('YouTube, Instagram, TikTok, Pinterest and many other supported public links.', style: TextStyle(color: Color(0xFF8F96A6))), const SizedBox(height: 22),
      Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [Expanded(child: TextField(controller: controller, onSubmitted: (_) => analyzing ? null : analyze(), decoration: InputDecoration(prefixIcon: Icon(Icons.link_rounded), hintText: ffTranslate('Paste media URL...')))), const SizedBox(width: 12), FilledButton.icon(onPressed: analyzing ? null : analyze, icon: analyzing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.travel_explore_rounded), label: const Text('Analyze'))]))),
      const SizedBox(height: 14), Row(children: [Icon(analyzing ? Icons.sync_rounded : Icons.info_outline_rounded, size: 17, color: const Color(0xFF8F96A6)), const SizedBox(width: 8), Expanded(child: Text(status, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF8F96A6))))]),
      if (active.isNotEmpty) ...[const SizedBox(height: 12), DownloadMiniBar(task: active.first)], const SizedBox(height: 18),
      if (media != null) Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(flex: 5, child: Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 150, height: 90, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(color: const Color(0xFF0E1117), borderRadius: BorderRadius.circular(10)), child: media!.thumbnail == null ? const Icon(Icons.movie_rounded, size: 38) : Image.network(media!.thumbnail!, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.movie_rounded, size: 38))), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(media!.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)), const SizedBox(height: 8), Text(media!.extractor, style: const TextStyle(color: Color(0xFF22D3EE), fontWeight: FontWeight.w600))]))]),
          const SizedBox(height: 18), const Text('Available formats', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 10),
          Expanded(child: ListView.separated(itemCount: media!.formats.length, separatorBuilder: (_,__) => const SizedBox(height: 7), itemBuilder: (_,i) { final f = media!.formats[i]; final selectedNow = identical(selected, f); return InkWell(onTap: () => setState(() => selected = f), borderRadius: BorderRadius.circular(11), child: Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11), decoration: BoxDecoration(color: selectedNow ? const Color(0xFF8B5CF6).withValues(alpha: .16) : const Color(0xFF10131A), border: Border.all(color: selectedNow ? const Color(0xFF8B5CF6) : const Color(0xFF292E3A)), borderRadius: BorderRadius.circular(11)), child: Row(children: [Icon(f.hasVideo ? Icons.videocam_rounded : Icons.audiotrack_rounded, size: 19, color: selectedNow ? const Color(0xFF8B5CF6) : const Color(0xFF8F96A6)), const SizedBox(width: 10), Expanded(child: Text('${f.label} • ${f.ext.toUpperCase()}')), Text(sizeText(f.filesize), style: const TextStyle(color: Color(0xFF858C9C), fontSize: 12))]))); }))
        ])))), const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Save destination', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<ProjectModel?>(
                          value: project,
                          isExpanded: true,
                          hint: const Text('Windows Downloads (default)'),
                          items: [
                            const DropdownMenuItem<ProjectModel?>(value: null, child: Text('Windows Downloads (default)')),
                            ...widget.projects.map((p) => DropdownMenuItem<ProjectModel?>(value: p, child: Text(p.name, overflow: TextOverflow.ellipsis))),
                          ],
                          onChanged: _selectProject,
                        ),
                        if (project != null) ...[
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String?>(
                            value: collection,
                            isExpanded: true,
                            decoration: InputDecoration(labelText: ffTranslate('Collection')),
                            hint: const Text('Unsorted'),
                            items: [
                              const DropdownMenuItem<String?>(value: null, child: Text('Unsorted')),
                              ...widget.downloadManager.libraryStore.collectionsFor(project!.id).map((c) => DropdownMenuItem<String?>(value: c, child: Text(c, overflow: TextOverflow.ellipsis))),
                            ],
                            onChanged: (v) => setState(() => collection = v),
                          ),
                        ],
                        const SizedBox(height: 14),
                        const Text('Download mode', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(value: false, label: Text('Full')),
                            ButtonSegment(value: true, label: Text('Clip'), icon: Icon(Icons.content_cut_rounded)),
                          ],
                          selected: {clipMode},
                          onSelectionChanged: (v) => setState(() => clipMode = v.first),
                        ),
                        if (clipMode) ...[
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(child: TextField(controller: clipStartController, decoration: InputDecoration(labelText: ffTranslate('Start'), hintText: ffTranslate('00:14:25')))),
                            const SizedBox(width: 10),
                            Expanded(child: TextField(controller: clipEndController, decoration: InputDecoration(labelText: ffTranslate('End'), hintText: ffTranslate('00:14:38')))),
                          ]),
                          const SizedBox(height:8),
                          TextField(controller:clipNameController,decoration:const InputDecoration(labelText:'Clip 1 name (optional)',hintText:'Leave empty to use time range')),
                          ...extraClips.asMap().entries.map((entry)=>Padding(
                            padding:const EdgeInsets.only(top:10),child:Column(children:[Row(children:[
                              Expanded(child:TextField(controller:entry.value.start,onChanged:(_)=>setState((){}),decoration:InputDecoration(labelText:'Clip ${entry.key+2} start'))),
                              const SizedBox(width:10),
                              Expanded(child:TextField(controller:entry.value.end,onChanged:(_)=>setState((){}),decoration:InputDecoration(labelText:'Clip ${entry.key+2} end'))),
                              IconButton(tooltip:'Remove clip',onPressed:(){setState(()=>extraClips.removeAt(entry.key));entry.value.dispose();},icon:const Icon(Icons.close_rounded))
                             ]),const SizedBox(height:6),TextField(controller:entry.value.name,decoration:InputDecoration(labelText:'Clip ${entry.key+2} name (optional)'))]))),
                           Align(alignment:Alignment.centerLeft,child:TextButton.icon(onPressed:()=>setState(()=>extraClips.add(ClipRangeEditor())),icon:const Icon(Icons.add_rounded),label:const Text('Add clip'))),
                          if(extraClips.isNotEmpty) ...[
                            const SizedBox(height:8),
                            SegmentedButton<String>(segments:const [
                              ButtonSegment(value:'multi',label:Text('Multi File')),
                              ButtonSegment(value:'single',label:Text('Single File')),
                            ],selected:{clipFileMode},onSelectionChanged:(v)=>setState(()=>clipFileMode=v.first)),
                          ],
                          const SizedBox(height: 6),
                          const Text('HH:MM:SS • Clips are processed in listed order', style: TextStyle(color: Color(0xFF858C9C), fontSize: 11)),
                           if(media?.durationSeconds!=null) Padding(padding:const EdgeInsets.only(top:5),child:Text('Video duration: ${_formatDuration(media!.durationSeconds!)}',style:const TextStyle(color:Color(0xFF8F96A6),fontSize:11))),
                           if(_clipValidation!=null) Padding(padding:const EdgeInsets.only(top:8),child:Text(_clipValidation!,style:const TextStyle(color:Color(0xFFFF6B6B),fontSize:12))),
                        ],
                        const SizedBox(height: 14),
                        if (!_isDirectOriginal) DropdownButtonFormField<String>(
                          value: outputMode,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: ffTranslate('Output')),
                          items: const ['Video + audio', 'Video only', 'Audio only', 'Edit-friendly MP4 (H.264)'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => outputMode = v ?? 'Video + audio'),
                        ),
                        const SizedBox(height: 14),
                        if (project == null)
                          const Text(r'No project selected • saves to Downloads\Footage Collector.', style: TextStyle(color: Color(0xFF8F96A6), fontSize: 12)),
                        if (selected != null && selected!.hasVideo && !selected!.hasAudio) ...[
                          const SizedBox(height: 8),
                          const Text('Video-only format: FFmpeg is required to merge the best audio. Configure ffmpeg.exe in Settings.', style: TextStyle(color: Color(0xFF8F96A6), fontSize: 12, height: 1.4)),
                        ],
                        const SizedBox(height: 18),
                        SizedBox(width: double.infinity, height: 46, child: FilledButton.icon(onPressed: selected == null || _clipValidation != null ? null : download, icon: const Icon(Icons.download_rounded), label: const Text('Add to downloads'))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ])) else Expanded(child: Card(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.cloud_download_outlined, size: 58, color: Colors.white.withValues(alpha: .2)), const SizedBox(height: 14), const Text('Paste a link and press Analyze', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 6), const Text('yt-dlp and FFmpeg are configured in Settings.', style: TextStyle(color: Color(0xFF858C9C))) ]))))
    ]));
  });
}

class DownloadMiniBar extends StatelessWidget {
  final DownloadTask task; const DownloadMiniBar({super.key, required this.task});
  @override Widget build(BuildContext context) => AnimatedBuilder(animation: task, builder: (_,__) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF13161D), border: Border.all(color: const Color(0xFF292E3A)), borderRadius: BorderRadius.circular(12)), child: Column(children: [Row(children: [const Icon(Icons.downloading_rounded, size: 18, color: Color(0xFF8B5CF6)), const SizedBox(width: 8), Expanded(child: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))), Text('${(task.progress*100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w700))]), const SizedBox(height: 9), LinearProgressIndicator(value: task.progress), const SizedBox(height: 7), Row(children: [Text(task.status, style: const TextStyle(color: Color(0xFF8F96A6), fontSize: 12)), const Spacer(), if (task.speed.isNotEmpty) Text(task.speed, style: const TextStyle(color: Color(0xFF8F96A6), fontSize: 12)), if (task.eta.isNotEmpty) Text('  •  ${task.eta}', style: const TextStyle(color: Color(0xFF8F96A6), fontSize: 12))])])));
}

Future<void> _showDownloadLog(BuildContext context, DownloadTask t) async {
  await showDialog(context:context,builder:(d)=>AlertDialog(
    title:Row(children:[const Expanded(child:Text('Download log')),IconButton(tooltip:ffTranslate('Copy log'),onPressed:()=>Clipboard.setData(ClipboardData(text:t.logLines.join('\n'))),icon:const Icon(Icons.copy_rounded))]),
    content:SizedBox(width:760,height:460,child:Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:const Color(0xFF090B10),borderRadius:BorderRadius.circular(10)),child:SingleChildScrollView(child:SelectableText(t.logLines.isEmpty?'No log output yet.':t.logLines.join('\n'),style:const TextStyle(fontFamily:'monospace',fontSize:11,height:1.45))))),
    actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('Close'))]));
}

class DownloadsPage extends StatefulWidget {
  final DownloadManager manager; final List<ProjectModel> projects;
  const DownloadsPage({super.key, required this.manager, required this.projects});
  @override State<DownloadsPage> createState()=>_DownloadsPageState();
}
class _DownloadsPageState extends State<DownloadsPage> {
  bool selectionMode=false; final Set<String> selected={};
  List<DownloadTask> get picked=>widget.manager.tasks.where((t)=>selected.contains(t.id)).toList();
  void toggle(DownloadTask t){setState((){selectionMode=true;if(!selected.add(t.id))selected.remove(t.id);if(selected.isEmpty)selectionMode=false;});}
  void clear(){setState((){selected.clear();selectionMode=false;});}
  Future<MapEntry<ProjectModel?,String?>?> chooseDestination() async {
    ProjectModel? project; String? collection;
    return showDialog<MapEntry<ProjectModel?,String?>>(context:context,builder:(d)=>StatefulBuilder(builder:(context,setD)=>AlertDialog(title:const Text('Download again'),content:SizedBox(width:430,child:Column(mainAxisSize:MainAxisSize.min,children:[DropdownButtonFormField<ProjectModel?>(value:project,decoration:InputDecoration(labelText:ffTranslate('Project')),items:[const DropdownMenuItem<ProjectModel?>(value:null,child:Text('Windows Downloads')),...widget.projects.map((p)=>DropdownMenuItem<ProjectModel?>(value:p,child:Text(p.name)))],onChanged:(v)=>setD((){project=v;collection=null;})),if(project!=null)...[const SizedBox(height:12),DropdownButtonFormField<String?>(value:collection,decoration:InputDecoration(labelText:ffTranslate('Collection')),items:[const DropdownMenuItem<String?>(value:null,child:Text('Unsorted')),...widget.manager.libraryStore.collectionsFor(project!.id).map((c)=>DropdownMenuItem<String?>(value:c,child:Text(c)))],onChanged:(v)=>setD(()=>collection=v))]])),actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(d,MapEntry(project,collection)),child:const Text('Continue'))])));
  }
  Future<void> bulkRedownload() async {final list=picked.where((t)=>t.done).toList();if(list.isEmpty)return;final dest=await chooseDestination();if(dest==null)return;clear();for(final t in list){unawaited(widget.manager.redownload(t,project:dest.key,collection:dest.value));}}
  @override Widget build(BuildContext context)=>AnimatedBuilder(animation:widget.manager,builder:(_,__) {final manager=widget.manager;final list=manager.tasks;final chosen=picked;final canPause=chosen.any((t)=>!t.done&&!t.failed&&!t.paused&&!t.cancelled);final canResume=chosen.any((t)=>t.paused);final canRetry=chosen.any((t)=>t.failed||t.cancelled);final canRedownload=chosen.any((t)=>t.done);return Padding(padding:const EdgeInsets.all(28),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    LayoutBuilder(builder:(context,c){final actions=Wrap(spacing:8,runSpacing:8,crossAxisAlignment:WrapCrossAlignment.center,children:!selectionMode?[OutlinedButton.icon(onPressed:list.isEmpty?null:()=>setState(()=>selectionMode=true),icon:const Icon(Icons.checklist_rounded),label:const Text('Select'))]:[Text('${selected.length} selected'),TextButton(onPressed:(){setState((){selected..clear()..addAll(list.map((e)=>e.id));});},child:const Text('Select all')),TextButton(onPressed:clear,child:const Text('Cancel'))]);return c.maxWidth<620?Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Downloads',style:TextStyle(fontSize:28,fontWeight:FontWeight.w800)),const SizedBox(height:12),actions]):Row(children:[const Expanded(child:Text('Downloads',style:TextStyle(fontSize:28,fontWeight:FontWeight.w800))),actions]);}),
    const SizedBox(height:6),Text(footageFlowLanguage.value == 'fa'
      ? '${manager.activeCount} فعال • ${list.where((t)=>t.done).length} تکمیل‌شده • ${list.where((t)=>t.cancelled).length} لغوشده'
      : '${manager.activeCount} active • ${list.where((t)=>t.done).length} completed • ${list.where((t)=>t.cancelled).length} cancelled',style:const TextStyle(color:Color(0xFF8F96A6))),
    if(selectionMode&&selected.isNotEmpty)...[const SizedBox(height:14),Wrap(spacing:8,runSpacing:8,children:[if(canPause)FilledButton.tonalIcon(onPressed:(){for(final t in chosen.where((t)=>!t.done&&!t.failed&&!t.paused&&!t.cancelled))unawaited(manager.pause(t));},icon:const Icon(Icons.pause_rounded),label:const Text('Pause')),if(canResume)FilledButton.tonalIcon(onPressed:(){for(final t in chosen.where((t)=>t.paused))unawaited(manager.resume(t));},icon:const Icon(Icons.play_arrow_rounded),label:const Text('Resume')),if(canRetry)FilledButton.tonalIcon(onPressed:(){for(final t in chosen.where((t)=>t.failed)){unawaited(manager.retry(t));}for(final t in chosen.where((t)=>t.cancelled)){t.cancelled=false;t.paused=true;unawaited(manager.resume(t));}},icon:const Icon(Icons.refresh_rounded),label:const Text('Retry')),if(canRedownload)FilledButton.tonalIcon(onPressed:bulkRedownload,icon:const Icon(Icons.download_rounded),label:const Text('Download again')),OutlinedButton.icon(onPressed:()async{final removing=List<DownloadTask>.from(chosen);for(final t in removing.where((t)=>!t.done&&!t.failed&&!t.cancelled&&!t.paused)){await manager.cancel(t);}await manager.removeFromHistory(removing);if(mounted)clear();},icon:const Icon(Icons.delete_outline_rounded),label:const Text('Remove from list'))]),],
    const SizedBox(height:18),Expanded(child:list.isEmpty?const Center(child:Text('No downloads yet',style:TextStyle(color:Color(0xFF858C9C)))):ListView.separated(itemCount:list.length,separatorBuilder:(_,__)=>const SizedBox(height:10),itemBuilder:(_,i){final t=list[i];final isSelected=selected.contains(t.id);return AnimatedBuilder(animation:t,builder:(_,__)=>Card(color:isSelected?const Color(0xFF211A35):null,child:InkWell(onTap:selectionMode?()=>toggle(t):null,onLongPress:()=>toggle(t),borderRadius:BorderRadius.circular(12),child:Padding(padding:const EdgeInsets.all(16),child:Row(children:[if(selectionMode)...[Checkbox(value:isSelected,onChanged:(_)=>toggle(t)),const SizedBox(width:8)],Container(width:110,height:66,clipBehavior:Clip.antiAlias,decoration:BoxDecoration(color:const Color(0xFF0E1117),borderRadius:BorderRadius.circular(9)),child:t.thumbnail==null?const Icon(Icons.movie_rounded):_thumbImage(t.thumbnail!,fallbackSize:28)),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t.title,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w700)),const SizedBox(height:5),Text('${t.projectName}  •  ${t.formatLabel}  •  ${t.createdAt.toLocal().toString().substring(0,16)}',style:const TextStyle(color:Color(0xFF8F96A6),fontSize:12)),const SizedBox(height:10),LinearProgressIndicator(value:t.failed?0:t.progress),const SizedBox(height:7),Row(children:[Expanded(child:Text(t.failed?(t.error??'Failed'):t.status,maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(color:t.failed?const Color(0xFFFF6B6B):const Color(0xFF8F96A6),fontSize:12))),const SizedBox(width:8),if(!selectionMode&&t.failed)TextButton.icon(onPressed:()=>manager.retry(t),icon:const Icon(Icons.refresh_rounded,size:16),label:const Text('Retry')),if(!selectionMode&&t.paused)TextButton.icon(onPressed:()=>manager.resume(t),icon:const Icon(Icons.play_arrow_rounded,size:17),label:const Text('Resume')),if(!selectionMode&&!t.done&&!t.failed&&!t.paused&&!t.cancelled)IconButton(tooltip:ffTranslate('Pause'),onPressed:()=>manager.pause(t),icon:const Icon(Icons.pause_rounded,size:19)),if(!selectionMode&&!t.done&&!t.cancelled)IconButton(tooltip:ffTranslate('Cancel'),onPressed:()=>manager.cancel(t),icon:const Icon(Icons.close_rounded,size:19)),const Spacer(),if(!t.done&&!t.failed&&!t.paused&&!t.cancelled&&t.speed.isNotEmpty)Text(t.speed,style:const TextStyle(color:Color(0xFF8F96A6),fontSize:12)),if(!t.done&&!t.failed&&!t.paused&&!t.cancelled&&t.eta.isNotEmpty)Text('  •  ETA ${t.eta}',style:const TextStyle(color:Color(0xFF8F96A6),fontSize:12)),const SizedBox(width:10),Text('${(t.progress*100).toStringAsFixed(1)}%',style:const TextStyle(fontWeight:FontWeight.w700))])])),if(!selectionMode)...[const SizedBox(width:8),IconButton(tooltip:ffTranslate('View log'),onPressed:()=>_showDownloadLog(context,t),icon:const Icon(Icons.receipt_long_rounded)),IconButton(tooltip:ffTranslate('Open folder'),onPressed:()=>Process.run('explorer.exe',[t.folder]),icon:const Icon(Icons.folder_open_rounded))]])))));}))
  ]));});
}

class LibraryPage extends StatefulWidget { final LibraryStore store; final List<ProjectModel> projects; const LibraryPage({super.key,required this.store,required this.projects}); @override State<LibraryPage> createState()=>_LibraryPageState(); }
class _LibraryPageState extends State<LibraryPage> {
 final search=TextEditingController(); final focusNode=FocusNode(); Timer? _searchDebounce; String? projectId; String resolution='All'; bool favorites=false; bool importing=false; bool selectionMode=false; final Set<String> selected={};
 @override void dispose(){_searchDebounce?.cancel();search.dispose();focusNode.dispose();super.dispose();}
 Future<void> importFootage() async {
  if(widget.projects.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Create a project first.')));return;}
  final picked=await FilePicker.platform.pickFiles(dialogTitle:ffTranslate('Import footage'),allowMultiple:true,type:FileType.custom,allowedExtensions:['mp4','mov','mkv','webm','avi','m4v','mp3','wav','m4a','aac','flac','ogg','png','jpg','jpeg','webp','gif','bmp']); if(picked==null||picked.files.isEmpty)return;if(!mounted)return;
  ProjectModel? target=widget.projects.length==1?widget.projects.first:null; target??=await showDialog<ProjectModel>(context:context,builder:(d)=>AlertDialog(title:const Text('Choose project'),content:SizedBox(width:380,child:Column(mainAxisSize:MainAxisSize.min,children:widget.projects.map((p)=>ListTile(leading:const Icon(Icons.folder_rounded),title:Text(p.name),onTap:()=>Navigator.pop(d,p))).toList())))); if(target==null)return;
  setState(()=>importing=true);var added=0,skipped=0;final pending=<LibraryItem>[];try{for(final pf in picked.files){final path=pf.path;if(path==null)continue;if(widget.store.items.any((e)=>e.filePath.toLowerCase()==path.toLowerCase())){skipped++;continue;}final f=File(path);if(!await f.exists())continue;final ext=(pf.extension??'').toLowerCase();final isImage=['png','jpg','jpeg','webp','gif','bmp'].contains(ext);final isAudio=['mp3','wav','m4a','aac','flac','ogg'].contains(ext);final meta=isImage?('Image',''):isAudio?('Audio',''):await _localVideoMeta(path);final thumb=isImage?path:(isAudio?null:await _makeLocalThumb(path));final size=await f.length();pending.add(LibraryItem(id:'local_${DateTime.now().microsecondsSinceEpoch}_${pending.length}',title:pf.name.replaceFirst(RegExp(r'\.[^.]+$'),''),filePath:path,projectId:target.id,projectName:target.name,formatLabel:'${meta.$1} • ${pf.extension?.toUpperCase()??'FILE'}',thumbnail:thumb,sizeBytes:size,addedAt:DateTime.now()));}added=await widget.store.addItems(pending);}finally{if(mounted)setState(()=>importing=false);}if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$added footage imported${skipped>0?' • $skipped already in Library':''}.')));
 }
 Future<(String,String)> _localVideoMeta(String path) async {try{final ff=DownloaderEngine.ffmpegPath;if(ff.isEmpty||!File(ff).existsSync())return('Local','');final r=await Process.run(ff,['-i',path]);final text='${r.stdout}\n${r.stderr}';final m=RegExp(r'(\d{3,5})x(\d{3,5})').firstMatch(text);if(m!=null){final h=int.tryParse(m.group(2)!)??0;final label=h>=2000?'2160p':h>=1300?'1440p':h>=900?'1080p':h>=650?'720p':h>=400?'480p':'${h}p';return(label,'${m.group(1)}x${m.group(2)}');}}catch(_){}return('Local','');}
 Future<String?> _makeLocalThumb(String path) async {try{final ff=DownloaderEngine.ffmpegPath;if(ff.isEmpty||!File(ff).existsSync())return null;final base='${Platform.environment['LOCALAPPDATA']??Directory.systemTemp.path}${Platform.pathSeparator}FootageCollector${Platform.pathSeparator}thumbnails';await Directory(base).create(recursive:true);final out='$base${Platform.pathSeparator}${DateTime.now().microsecondsSinceEpoch}.jpg';final r=await Process.run(ff,['-y','-ss','00:00:01','-i',path,'-frames:v','1','-q:v','2',out]);return r.exitCode==0&&File(out).existsSync()?out:null;}catch(_){return null;}}
 void toggleSelection(LibraryItem item){setState((){selectionMode=true;if(!selected.add(item.id))selected.remove(item.id);if(selected.isEmpty)selectionMode=false;});}
 void clearSelection()=>setState((){selected.clear();selectionMode=false;});
 String _uniquePath(String path){if(!File(path).existsSync())return path;final sep=Platform.pathSeparator,slash=path.lastIndexOf(sep),dot=path.lastIndexOf('.');final dir=slash>=0?path.substring(0,slash+1):'',nameEnd=dot>slash?dot:path.length,base=path.substring(slash+1,nameEnd),ext=dot>slash?path.substring(dot):'';var n=2;while(File('$dir$base ($n)$ext').existsSync())n++;return '$dir$base ($n)$ext';}
 Future<void> transferSelected({required bool copy}) async {
  final moving=widget.store.items.where((e)=>selected.contains(e.id)).toList();if(moving.isEmpty)return;
  final target=await showDialog<ProjectModel>(context:context,builder:(d)=>AlertDialog(title:Text('${copy?'Copy':'Move'} ${moving.length} item${moving.length==1?'':'s'} to project'),content:SizedBox(width:400,child:Column(mainAxisSize:MainAxisSize.min,children:widget.projects.map((p)=>ListTile(leading:const Icon(Icons.folder_rounded),title:Text(p.name),subtitle:Text(p.path,maxLines:1,overflow:TextOverflow.ellipsis),onTap:()=>Navigator.pop(d,p))).toList()))));if(target==null||!mounted)return;
  String? collection;final cols=widget.store.collectionsFor(target.id);if(cols.isNotEmpty){collection=await showDialog<String>(context:context,builder:(d)=>SimpleDialog(title:const Text('Destination collection (optional)'),children:[SimpleDialogOption(onPressed:()=>Navigator.pop(d,'__none__'),child:const Text('Unsorted')),...cols.map((c)=>SimpleDialogOption(onPressed:()=>Navigator.pop(d,c),child:Text(c)))]));if(collection==null)return;if(collection=='__none__')collection=null;}
  var conflict='ask',moved=0,skipped=0,failed=0;
  for(final item in moving){try{final src=File(item.filePath);if(!await src.exists()){failed++;continue;}await Directory(target.path).create(recursive:true);var dest='${target.path}${Platform.pathSeparator}${item.filePath.split(Platform.pathSeparator).last}';if(src.path.toLowerCase()==dest.toLowerCase()){await widget.store.updateMovedItem(item,filePath:dest,project:target,collection:collection);moved++;continue;}if(await File(dest).exists()){var choice=conflict;if(conflict=='ask'){if(!mounted)return;choice=await showDialog<String>(context:context,builder:(d)=>AlertDialog(title:const Text('File already exists'),content:Text('${dest.split(Platform.pathSeparator).last} already exists in ${target.name}.'),actions:[TextButton(onPressed:()=>Navigator.pop(d,'skip'),child:const Text('Skip')),TextButton(onPressed:()=>Navigator.pop(d,'keep'),child:const Text('Keep both')),FilledButton(onPressed:()=>Navigator.pop(d,'replace'),child:const Text('Replace'))]))??'skip';}if(choice=='skip'){skipped++;continue;}if(choice=='keep')dest=_uniquePath(dest);if(choice=='replace')await File(dest).delete();}
    if(copy){await src.copy(dest);final cloned=LibraryItem(id:'copy_${DateTime.now().microsecondsSinceEpoch}_${item.id}',title:item.title,filePath:dest,projectId:target.id,projectName:target.name,formatLabel:item.formatLabel,thumbnail:item.thumbnail==item.filePath?dest:item.thumbnail,collection:collection,sourceUrl:item.sourceUrl,outputMode:item.outputMode,clipStart:item.clipStart,clipEnd:item.clipEnd,sizeBytes:item.sizeBytes,addedAt:DateTime.now(),favorite:item.favorite,tags:item.tags);await widget.store.addItem(cloned);}else{try{await src.rename(dest);}catch(_){await src.copy(dest);await src.delete();}await widget.store.updateMovedItem(item,filePath:dest,project:target,collection:collection);}moved++;
   }catch(_){failed++;}}
  if(mounted){clearSelection();ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$moved ${copy?'copied':'moved'}${skipped>0?' • $skipped skipped':''}${failed>0?' • $failed failed':''}.')));}
 }
 @override Widget build(BuildContext context)=>AnimatedBuilder(animation:widget.store,builder:(_,__){var list=List<LibraryItem>.of(widget.store.items);final q=search.text.trim().toLowerCase();if(q.isNotEmpty)list=list.where((e)=>e.title.toLowerCase().contains(q)||e.projectName.toLowerCase().contains(q)||e.tags.any((t)=>t.toLowerCase().contains(q))).toList();if(projectId!=null)list=list.where((e)=>e.projectId==projectId).toList();if(resolution!='All')list=list.where((e)=>e.formatLabel.contains(resolution)).toList();if(favorites)list=list.where((e)=>e.favorite).toList();final total=widget.store.items.fold<int>(0,(a,b)=>a+b.sizeBytes);
  return KeyboardListener(focusNode:focusNode,autofocus:true,onKeyEvent:(e){if(e is KeyDownEvent&&HardwareKeyboard.instance.isControlPressed&&e.logicalKey==LogicalKeyboardKey.keyA){setState((){selectionMode=true;selected.addAll(list.map((e)=>e.id));});}},child:Padding(padding:const EdgeInsets.all(28),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   LayoutBuilder(builder:(context,c){final compact=c.maxWidth<850;final title=const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Library',maxLines:1,overflow:TextOverflow.ellipsis,style:TextStyle(fontSize:28,fontWeight:FontWeight.w800)),SizedBox(height:5),Text('Everything you collected, searchable and organized.',maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(color:Color(0xFF8F96A6)))]);final actions=Wrap(spacing:8,runSpacing:8,crossAxisAlignment:WrapCrossAlignment.center,children:selectionMode?[Text('${selected.length} selected',style:const TextStyle(fontWeight:FontWeight.w700)),FilledButton.icon(onPressed:selected.isEmpty?null:()=>transferSelected(copy:false),icon:const Icon(Icons.drive_file_move_rounded),label:const Text('Move to project')),OutlinedButton.icon(onPressed:selected.isEmpty?null:()=>transferSelected(copy:true),icon:const Icon(Icons.copy_rounded),label:const Text('Copy to project')),OutlinedButton(onPressed:clearSelection,child:const Text('Cancel'))]:[OutlinedButton.icon(onPressed:()=>setState(()=>selectionMode=true),icon:const Icon(Icons.checklist_rounded),label:const Text('Select')),FilledButton.icon(onPressed:importing?null:importFootage,icon:importing?const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.add_rounded),label:Text(importing?'Importing...':'Import footage')),Text('${widget.store.items.length} items • ${_size(total)}',style:const TextStyle(color:Color(0xFF8F96A6)))]);return compact?Column(crossAxisAlignment:CrossAxisAlignment.start,children:[title,const SizedBox(height:14),Align(alignment:Alignment.centerRight,child:actions)]):Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:title),const SizedBox(width:24),Align(alignment:Alignment.topRight,child:actions)]);}),const SizedBox(height:20),
   LayoutBuilder(builder:(context,c){
     final searchBox=TextField(controller:search,onChanged:(_){_searchDebounce?.cancel();_searchDebounce=Timer(const Duration(milliseconds:120),(){if(mounted)setState((){});});},decoration:InputDecoration(prefixIcon:Icon(Icons.search_rounded),hintText:ffTranslate('Search footage...')));
     Widget projectFilter=DropdownButtonFormField<String?>(isExpanded:true,value:projectId,hint:const Text('All projects',overflow:TextOverflow.ellipsis),items:[const DropdownMenuItem<String?>(value:null,child:Text('All projects',overflow:TextOverflow.ellipsis)),...widget.projects.map((p)=>DropdownMenuItem<String?>(value:p.id,child:Text(p.name,overflow:TextOverflow.ellipsis)))],onChanged:(v)=>setState(()=>projectId=v));
     Widget qualityFilter=DropdownButtonFormField<String>(isExpanded:true,value:resolution,items:['All','2160p','1440p','1080p','720p','480p'].map((e)=>DropdownMenuItem(value:e,child:Text(e=='All'?'All quality':e,overflow:TextOverflow.ellipsis))).toList(),onChanged:(v)=>setState(()=>resolution=v??'All'));
     final favoriteFilter=FilterChip(selected:favorites,onSelected:(v)=>setState(()=>favorites=v),avatar:const Icon(Icons.star_rounded,size:17),label:const Text('Favorites'));
     if(c.maxWidth<720){return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[searchBox,const SizedBox(height:10),projectFilter,const SizedBox(height:10),qualityFilter,const SizedBox(height:10),Align(alignment:Alignment.centerLeft,child:favoriteFilter)]);}
     if(c.maxWidth<1180){return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[searchBox,const SizedBox(height:10),Row(children:[Expanded(flex:3,child:projectFilter),const SizedBox(width:10),Expanded(flex:2,child:qualityFilter),const SizedBox(width:10),favoriteFilter])]);}
     return Row(children:[Expanded(child:searchBox),const SizedBox(width:10),SizedBox(width:190,child:projectFilter),const SizedBox(width:10),SizedBox(width:145,child:qualityFilter),const SizedBox(width:10),favoriteFilter]);
   }),const SizedBox(height:18),
   Expanded(child:list.isEmpty?const Center(child:Text('No footage matches these filters.',style:TextStyle(color:Color(0xFF858C9C)))):LibraryGrid(items:list,store:widget.store,projects:widget.projects,selectionMode:selectionMode,selected:selected,onToggle:toggleSelection))
  ])));
 });
}
void _noopLibraryToggle(LibraryItem _) {}
class LibraryGrid extends StatelessWidget {
 final List<LibraryItem> items; final LibraryStore store; final List<ProjectModel> projects; final bool selectionMode; final Set<String> selected; final ValueChanged<LibraryItem> onToggle;
 const LibraryGrid({super.key,required this.items,required this.store,required this.projects,this.selectionMode=false,this.selected=const <String>{},this.onToggle=_noopLibraryToggle});
 @override Widget build(BuildContext context)=>LayoutBuilder(builder:(context,c){
   final n=c.maxWidth>1050?4:c.maxWidth>760?3:c.maxWidth>480?2:1;
   // Build the selected drag payload once, not once per visible card.
   final selectedPaths=selectionMode&&selected.isNotEmpty?items.where((e)=>selected.contains(e.id)).map((e)=>e.filePath).toList(growable:false):const <String>[];
   return GridView.builder(
     cacheExtent:420,
     addAutomaticKeepAlives:false,
     addRepaintBoundaries:true,
     gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:n,crossAxisSpacing:12,mainAxisSpacing:12,childAspectRatio:1.28),
     itemCount:items.length,
     itemBuilder:(_,i){final item=items[i];return RepaintBoundary(child:LibraryCard(item:item,store:store,projects:projects,selectionMode:selectionMode,selected:selected.contains(item.id),onToggle:()=>onToggle(item),dragPaths:(selectionMode&&selected.contains(item.id))?selectedPaths:<String>[item.filePath]));}
   );
 });
}
class LibraryCard extends StatelessWidget { final LibraryItem item;final LibraryStore store;final List<ProjectModel> projects;final bool selectionMode,selected;final VoidCallback? onToggle;final List<String> dragPaths;const LibraryCard({super.key,required this.item,required this.store,required this.projects,this.selectionMode=false,this.selected=false,this.onToggle,this.dragPaths=const <String>[]});
 String get _mediaType=>_libraryMediaType(item.filePath,item.formatLabel);
 Future<void> editTags(BuildContext context) async {
   final controller=TextEditingController(text:item.tags.join(', '));
   final result=await showDialog<String>(context:context,builder:(d)=>AlertDialog(title:Text('Tags • ${item.title}',maxLines:2),content:SizedBox(width:440,child:TextField(controller:controller,autofocus:true,maxLines:3,decoration:const InputDecoration(labelText:'Tags',hintText:'cinematic, nature, intro',helperText:'Separate tags with commas'))),actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(d,controller.text),child:const Text('Save'))]));
   controller.dispose();if(result==null)return;
   final unique=<String>{};final tags=<String>[];
   for(final part in result.split(',')){final t=part.trim();if(t.isNotEmpty&&unique.add(t.toLowerCase()))tags.add(t);}
   await store.updateTags(item,tags);
 }
 IconData get _mediaIcon=>_mediaType=='Audio'?Icons.music_note_rounded:_mediaType=='Image'?Icons.image_rounded:Icons.videocam_rounded; Future<void> details(BuildContext context) async { await showDialog(context:context,builder:(d)=>AlertDialog(title:Text(item.title,maxLines:2,overflow:TextOverflow.ellipsis),content:ConstrainedBox(constraints:BoxConstraints(maxWidth:560,maxHeight:MediaQuery.sizeOf(d).height*0.72),child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[Container(height:250,width:double.infinity,clipBehavior:Clip.antiAlias,decoration:BoxDecoration(color:const Color(0xFF0E1117),borderRadius:BorderRadius.circular(12)),child:item.thumbnail==null?Icon(_mediaIcon,size:60):_thumbImage(item.thumbnail!,fallbackSize:60)),const SizedBox(height:14),Text('${item.projectName} • ${item.formatLabel} • ${_size(item.sizeBytes)}',style:const TextStyle(color:Color(0xFF8F96A6))),const SizedBox(height:8),SelectableText(item.filePath,style:const TextStyle(fontSize:12,color:Color(0xFF858C9C))),const SizedBox(height:14),Container(width:double.infinity,padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:const Color(0xFF0E1117),borderRadius:BorderRadius.circular(10)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Source',style:TextStyle(fontWeight:FontWeight.w700)),const SizedBox(height:6),SelectableText(item.sourceUrl?.isNotEmpty==true?item.sourceUrl!:'Local import',style:TextStyle(fontSize:12,color:item.sourceUrl?.isNotEmpty==true?const Color(0xFF22D3EE):const Color(0xFF858C9C))),if(item.sourceUrl?.isNotEmpty==true)...[const SizedBox(height:8),Wrap(spacing:8,children:[TextButton.icon(onPressed:()=>Clipboard.setData(ClipboardData(text:item.sourceUrl!)),icon:const Icon(Icons.copy_rounded,size:16),label:const Text('Copy link')),TextButton.icon(onPressed:()=>Process.run('cmd',['/c','start','',item.sourceUrl!],runInShell:true),icon:const Icon(Icons.open_in_new_rounded,size:16),label:const Text('Open source'))])]])),const SizedBox(height:14),Wrap(spacing:6,runSpacing:6,children:[...item.tags.map((t)=>Chip(label:Text(t))),ActionChip(avatar:const Icon(Icons.edit_outlined,size:16),label:const Text('Edit tags'),onPressed:(){Navigator.pop(d);editTags(context);})]),const SizedBox(height:14),DropdownButtonFormField<String?>(value:item.collection,hint:const Text('No collection'),items:[const DropdownMenuItem<String?>(value:null,child:Text('No collection')),...store.collectionsFor(item.projectId).map((e)=>DropdownMenuItem<String?>(value:e,child:Text(e)))],onChanged:(v){store.moveToCollection(item,v);Navigator.pop(d);})]))),actions:[TextButton.icon(onPressed:() async {
    final choice=await showDialog<String>(context:context,builder:(c)=>AlertDialog(
      title:const Text('Refresh thumbnail'),
      content:const Text('Use the highest available source image, or extract a high-quality frame from this video.'),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Cancel')),
        OutlinedButton(onPressed:()=>Navigator.pop(c,'frame'),child:const Text('Video frame')),
        FilledButton(onPressed:()=>Navigator.pop(c,'source'),child:const Text('Original thumbnail')),
      ]));
    if(choice==null)return;
    if(!context.mounted)return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Refreshing thumbnail...')));
    try {
      final thumb=await _refreshHighQualityThumbnail(item,useVideoFrame:choice=='frame');
      if(thumb==null)throw StateError('No thumbnail was generated.');
      await store.updateThumbnail(item,thumb);
      if(context.mounted) {
        Navigator.pop(d);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Thumbnail refreshed.')));
      }
    } catch(e) {
      if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Thumbnail refresh failed: $e')));
    }
  },icon:const Icon(Icons.refresh_rounded),label:const Text('Refresh thumbnail')),TextButton.icon(onPressed:(){Process.run('explorer.exe',['/select,',item.filePath]);},icon:const Icon(Icons.folder_open_rounded),label:const Text('Show in folder')),TextButton.icon(onPressed:(){Process.run(item.filePath,[],runInShell:true);},icon:const Icon(Icons.play_arrow_rounded),label:const Text('Open file')),PopupMenuButton<String>(onSelected:(v)async{Navigator.pop(d);if(v=='library')await store.remove(item);if(v=='disk')await store.remove(item,deleteFile:true);},itemBuilder:(_)=>const [PopupMenuItem(value:'library',child:Text('Remove from Library')),PopupMenuItem(value:'disk',child:Text('Delete file from disk',style:TextStyle(color:Color(0xFFFF6B6B))))],child:const Padding(padding:EdgeInsets.all(10),child:Icon(Icons.delete_outline_rounded))) ])); }
 Future<void> contextMenu(BuildContext context, TapDownDetails d) async {
  final overlay=Overlay.of(context).context.findRenderObject() as RenderBox;
  final v=await showMenu<String>(context:context,position:RelativeRect.fromRect(Rect.fromPoints(d.globalPosition,d.globalPosition),Offset.zero&overlay.size),items:const [
    PopupMenuItem(value:'folder',child:ListTile(leading:Icon(Icons.folder_open_rounded),title:Text('Show in folder'),dense:true,contentPadding:EdgeInsets.zero)),
    PopupMenuItem(value:'open',child:ListTile(leading:Icon(Icons.play_arrow_rounded),title:Text('Open file'),dense:true,contentPadding:EdgeInsets.zero)),
    PopupMenuItem(value:'collection',child:ListTile(leading:Icon(Icons.folder_copy_rounded),title:Text('Move to collection'),trailing:Icon(Icons.chevron_right_rounded),dense:true,contentPadding:EdgeInsets.zero)),
    PopupMenuDivider(),
    PopupMenuItem(value:'remove',child:ListTile(leading:Icon(Icons.remove_circle_outline_rounded),title:Text('Remove from Library'),dense:true,contentPadding:EdgeInsets.zero)),
    PopupMenuItem(value:'delete',child:ListTile(leading:Icon(Icons.delete_outline_rounded,color:Color(0xFFFF6B6B)),title:Text('Delete file from disk',style:TextStyle(color:Color(0xFFFF6B6B))),dense:true,contentPadding:EdgeInsets.zero)),
  ]);
  if(v=='folder') Process.run('explorer.exe',['/select,',item.filePath]);
  if(v=='open') Process.run(item.filePath,[],runInShell:true);
  if(v=='collection' && context.mounted){
    final cols=store.collectionsFor(item.projectId);
    final choice=await showDialog<String?>(context:context,builder:(d)=>SimpleDialog(title:const Text('Move to collection'),children:[SimpleDialogOption(onPressed:()=>Navigator.pop(d,'__unsorted__'),child:Row(children:[Icon(item.collection==null?Icons.check_rounded:Icons.folder_off_outlined),const SizedBox(width:10),const Text('Unsorted')])),...cols.map((c)=>SimpleDialogOption(onPressed:()=>Navigator.pop(d,c),child:Row(children:[Icon(item.collection==c?Icons.check_rounded:Icons.folder_rounded),const SizedBox(width:10),Expanded(child:Text(c))])))]));
    if(choice!=null)await store.moveToCollection(item,choice=='__unsorted__'?null:choice);
  }
  if(v=='remove') await store.remove(item);
  if(v=='delete' && context.mounted){
    final ok=await showDialog<bool>(context:context,builder:(d)=>AlertDialog(title:const Text('Delete file?'),content:Text('This will permanently delete “${item.title}” from disk.'),actions:[TextButton(onPressed:()=>Navigator.pop(d,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(d,true),style:FilledButton.styleFrom(backgroundColor:const Color(0xFFFF5C5C)),child:const Text('Delete'))]))??false;
    if(ok) await store.remove(item,deleteFile:true);
  }
 }
 @override Widget build(BuildContext context){
  final card=GestureDetector(onSecondaryTapDown:(d){if(!selectionMode)contextMenu(context,d);},child:Card(clipBehavior:Clip.antiAlias,shape:selected?RoundedRectangleBorder(side:const BorderSide(color:Color(0xFF8B5CF6),width:2),borderRadius:BorderRadius.circular(12)):null,child:InkWell(onTap:(){if(selectionMode||HardwareKeyboard.instance.isControlPressed){onToggle?.call();}else{details(context);}},child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:Stack(fit:StackFit.expand,children:[item.thumbnail==null?ColoredBox(color:const Color(0xFF0E1117),child:Icon(_mediaIcon,size:46)):_thumbImage(item.thumbnail!,fallbackSize:46),Positioned(top:8,left:8,child:_MediaTypeBadge(type:_mediaType)),Positioned(top:39,left:8,child:_SourceBadge(url:item.sourceUrl)),if(selectionMode)Positioned(bottom:8,left:8,child:Container(width:25,height:25,decoration:BoxDecoration(color:selected?const Color(0xFF8B5CF6):Colors.black54,shape:BoxShape.circle,border:Border.all(color:Colors.white70)),child:Icon(selected?Icons.check_rounded:Icons.circle_outlined,size:17,color:Colors.white))),Positioned(top:7,right:7,child:Material(color:Colors.black54,borderRadius:BorderRadius.circular(20),child:IconButton(visualDensity:VisualDensity.compact,onPressed:()=>store.toggleFavorite(item),icon:Icon(item.favorite?Icons.star_rounded:Icons.star_border_rounded,color:item.favorite?const Color(0xFFFFC857):Colors.white))))])),Padding(padding:const EdgeInsets.all(11),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(item.title,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w700)),const SizedBox(height:5),Text(item.tags.isEmpty?'${item.projectName} • ${item.formatLabel}':'${item.projectName} • ${item.tags.join(' • ')}',maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(color:Color(0xFF8F96A6),fontSize:11)),const SizedBox(height:3),Row(children:[Expanded(child:Text(item.collection??'Unsorted',overflow:TextOverflow.ellipsis,style:const TextStyle(color:Color(0xFF22D3EE),fontSize:11))),Text(_size(item.sizeBytes),style:const TextStyle(color:Color(0xFF858C9C),fontSize:11))])]))]))));
  return GestureDetector(
    behavior:HitTestBehavior.translucent,
    onHorizontalDragStart:(_)=>_NativeFileDrag.start(dragPaths.isEmpty?<String>[item.filePath]:dragPaths),
    child:card,
  );
 }
}

String _libraryMediaType(String path,String formatLabel){
 final ext=path.split('.').last.toLowerCase();
 const audio={'mp3','m4a','aac','wav','flac','ogg','opus','wma'};
 const images={'jpg','jpeg','png','webp','gif','bmp','tif','tiff'};
 if(audio.contains(ext))return 'Audio';
 if(images.contains(ext))return 'Image';
 return 'Video';
}
String _sourceKind(String? url){
 final u=(url??'').toLowerCase();
 if(u.isEmpty)return 'LOCAL';
 if(u.contains('youtube.com')||u.contains('youtu.be'))return 'YT';
 if(u.contains('tiktok.com'))return 'TT';
 if(u.contains('instagram.com'))return 'IG';
 if(u.contains('pinterest.')||u.contains('pin.it'))return 'PIN';
 return 'WEB';
}
class _SourceBadge extends StatelessWidget{final String? url;const _SourceBadge({required this.url});@override Widget build(BuildContext context){final k=_sourceKind(url);final icon=k=='YT'?Icons.play_arrow_rounded:k=='IG'?Icons.camera_alt_rounded:k=='TT'?Icons.music_note_rounded:k=='PIN'?Icons.push_pin_rounded:k=='LOCAL'?Icons.folder_rounded:Icons.public_rounded;return Tooltip(message:k=='YT'?'YouTube':k=='IG'?'Instagram':k=='TT'?'TikTok':k=='PIN'?'Pinterest':k=='LOCAL'?'Local import':'Website',child:Container(padding:const EdgeInsets.symmetric(horizontal:6,vertical:4),decoration:BoxDecoration(color:Colors.black.withValues(alpha:.76),borderRadius:BorderRadius.circular(7),border:Border.all(color:Colors.white.withValues(alpha:.13))),child:Row(mainAxisSize:MainAxisSize.min,children:[Icon(icon,size:12,color:Colors.white),const SizedBox(width:3),Text(k,style:const TextStyle(color:Colors.white,fontSize:9,fontWeight:FontWeight.w800))])));}}

class _MediaTypeBadge extends StatelessWidget{final String type;const _MediaTypeBadge({required this.type});@override Widget build(BuildContext context){final icon=type=='Audio'?Icons.music_note_rounded:type=='Image'?Icons.image_rounded:Icons.videocam_rounded;return Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:5),decoration:BoxDecoration(color:Colors.black.withValues(alpha:.72),borderRadius:BorderRadius.circular(9),border:Border.all(color:Colors.white.withValues(alpha:.13))),child:Row(mainAxisSize:MainAxisSize.min,children:[Icon(icon,size:14,color:Colors.white),const SizedBox(width:5),Text(type,style:const TextStyle(color:Colors.white,fontSize:10,fontWeight:FontWeight.w700))]));}}

Widget _thumbImage(String source,{double fallbackSize=46}) { final fallback=ColoredBox(color:const Color(0xFF0E1117),child:Icon(Icons.movie_rounded,size:fallbackSize)); final low=source.toLowerCase(); if(low.startsWith('http://')||low.startsWith('https://')) return Image.network(source,fit:BoxFit.cover,cacheWidth:256,errorBuilder:(_,__,___)=>fallback); return Image.file(File(source),fit:BoxFit.cover,cacheWidth:256,filterQuality:FilterQuality.low,errorBuilder:(_,__,___)=>fallback); }

String _size(int bytes){if(bytes>=1073741824)return '${(bytes/1073741824).toStringAsFixed(1)} GB';if(bytes>=1048576)return '${(bytes/1048576).toStringAsFixed(1)} MB';if(bytes>=1024)return '${(bytes/1024).toStringAsFixed(0)} KB';return '$bytes B';}



class ShareCenterPage extends StatefulWidget {
  final LibraryStore store;
  final List<ProjectModel> projects;
  final DownloadManager manager;
  const ShareCenterPage({super.key, required this.store, required this.projects, required this.manager});
  @override State<ShareCenterPage> createState()=>_ShareCenterPageState();
}

class _ShareCenterPageState extends State<ShareCenterPage> {
  final Set<String> selected={};
  bool busy=false;

  List<LibraryItem> get shareable=>widget.store.items.where((e)=>e.sourceUrl?.trim().isNotEmpty==true).toList();

  Map<String,dynamic> _entry(LibraryItem e)=>{
    'title':e.title,
    'sourceUrl':e.sourceUrl,
    'formatLabel':e.formatLabel,
    'collection':e.collection,
    'mediaType':_libraryMediaType(e.filePath,e.formatLabel),
    'outputMode':e.outputMode??'Video + audio',
    'downloadMode':(e.clipStart?.isNotEmpty==true&&e.clipEnd?.isNotEmpty==true)?'clip':'full',
    'clipStart':e.clipStart,
    'clipEnd':e.clipEnd,
  };

  Future<void> _writePack(String name,List<LibraryItem> items,{ProjectModel? project}) async {
    final valid=items.where((e)=>e.sourceUrl?.trim().isNotEmpty==true).toList();
    final excluded=items.length-valid.length;
    if(valid.isEmpty){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Nothing shareable. Local imports do not contain a source link.')));return;}
    final safe=name.replaceAll(RegExp(r'[<>:"/\\|?*]'),'_');
    final path=await FilePicker.platform.saveFile(dialogTitle:'Save Footage Collector share pack',fileName:'$safe.fcshare',type:FileType.custom,allowedExtensions:['fcshare']);
    if(path==null)return;
    final payload={
      'app':'Footage Collector','version':2,'createdAt':DateTime.now().toIso8601String(),
      'project':project==null?null:{'name':project.name,'collections':widget.store.collectionsFor(project.id)},
      'items':valid.map(_entry).toList(),
    };
    final out=path.toLowerCase().endsWith('.fcshare')?path:'$path.fcshare';
    await File(out).writeAsString(const JsonEncoder.withIndent('  ').convert(payload),flush:true);
    if(!mounted)return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('${valid.length} item${valid.length==1?'':'s'} shared${excluded>0?' • $excluded local import${excluded==1?'':'s'} excluded':''}.')));
  }

  Future<Object?> _chooseDestination() async {
    if(!mounted)return null;
    return showDialog<Object>(context:context,builder:(d)=>AlertDialog(
      title:const Text('Where should downloads go?'),
      content:SizedBox(width:420,child:Column(mainAxisSize:MainAxisSize.min,children:[
        ListTile(leading:const Icon(Icons.download_rounded),title:const Text('Windows Downloads'),subtitle:const Text('Do not assign to a project'),onTap:()=>Navigator.pop(d,'__windows__')),
        const Divider(),
        ...widget.projects.map((p)=>ListTile(leading:const Icon(Icons.folder_rounded),title:Text(p.name),subtitle:Text(p.path,maxLines:1,overflow:TextOverflow.ellipsis),onTap:()=>Navigator.pop(d,p)))
      ])),
      actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('Cancel'))],
    ));
  }

  MediaFormat _pickFormat(AnalyzedMedia media,String wanted){
    final low=wanted.toLowerCase();
    final ext=RegExp(r'•\s*([a-z0-9]+)',caseSensitive:false).firstMatch(wanted)?.group(1)?.toLowerCase();
    final h=int.tryParse(RegExp(r'(\d{3,4})p').firstMatch(low)?.group(1)??'');
    final candidates=media.formats.where((f)=>(ext==null||f.ext.toLowerCase()==ext)&&(h==null||f.height==h)).toList();
    if(candidates.isNotEmpty)return candidates.first;
    if(h!=null){final q=media.formats.where((f)=>f.height==h).toList();if(q.isNotEmpty)return q.first;}
    return media.formats.first;
  }

  Future<void> _importPack() async {
    final pick=await FilePicker.platform.pickFiles(dialogTitle:'Import .fcshare',type:FileType.custom,allowedExtensions:['fcshare']);
    final path=pick?.files.single.path;if(path==null)return;
    Map<String,dynamic> data;
    try{data=Map<String,dynamic>.from(jsonDecode(await File(path).readAsString()) as Map);}catch(_){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('This is not a valid Footage Collector share pack.')));return;}
    final raw=(data['items'] as List? ?? const []);
    if(raw.isEmpty){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('This share pack is empty.')));return;}
    final destination=await _chooseDestination();
    if(destination==null||!mounted)return;
    final ProjectModel? project=destination is ProjectModel ? destination : null;
    final ok=await showDialog<bool>(context:context,builder:(d)=>AlertDialog(title:const Text('Import shared downloads?'),content:Text('${raw.length} item${raw.length==1?'':'s'} will be analyzed and added to Downloads${project==null?' (Windows Downloads)':' → ${project.name}'}.'),actions:[TextButton(onPressed:()=>Navigator.pop(d,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(d,true),child:const Text('Add to downloads'))]))??false;
    if(!ok)return;
    setState(()=>busy=true);
    var added=0,failed=0;
    try{
      for(final x in raw){
        final m=Map<String,dynamic>.from(x as Map);final url='${m['sourceUrl']??''}'.trim();if(url.isEmpty){failed++;continue;}
        try{
          final media=await DownloaderEngine.analyze(url);
          if(media.formats.isEmpty){failed++;continue;}
          final format=_pickFormat(media,'${m['formatLabel']??''}');
          final collection=project==null?null:(m['collection'] as String?);
          if(project!=null&&collection!=null&&collection.trim().isNotEmpty)await widget.store.addCollection(project.id,collection);
          final clipStart=m['downloadMode']=='clip' ? (m['clipStart'] as String?) : null;
          final clipEnd=m['downloadMode']=='clip' ? (m['clipEnd'] as String?) : null;
          final outputMode='${m['outputMode']??'Video + audio'}';
          unawaited(widget.manager.start(url:url,format:format,media:media,project:project,collection:collection,outputMode:outputMode,clipStart:clipStart,clipEnd:clipEnd));
          added++;
        }catch(_){failed++;}
      }
    }finally{if(mounted)setState(()=>busy=false);}
    if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$added added to Downloads${failed>0?' • $failed could not be analyzed':''}.')));
  }

  Future<void> _shareProject() async {
    if(widget.projects.isEmpty)return;
    final p=await showDialog<ProjectModel>(context:context,builder:(d)=>SimpleDialog(title:const Text('Share entire project'),children:widget.projects.map((p)=>SimpleDialogOption(onPressed:()=>Navigator.pop(d,p),child:ListTile(leading:const Icon(Icons.folder_rounded),title:Text(p.name),subtitle:Text('${widget.store.items.where((e)=>e.projectId==p.id&&e.sourceUrl?.isNotEmpty==true).length} shareable')))).toList()));
    if(p==null)return;
    await _writePack(p.name,widget.store.items.where((e)=>e.projectId==p.id).toList(),project:p);
  }

  @override Widget build(BuildContext context)=>AnimatedBuilder(animation:widget.store,builder:(_,__) {
    final items=shareable;
    return Padding(padding:const EdgeInsets.all(28),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Share',style:TextStyle(fontSize:28,fontWeight:FontWeight.w800)),SizedBox(height:5),Text('Send source links as a tiny .fcshare pack — never the local media files.',style:TextStyle(color:Color(0xFF8F96A6)))])),OutlinedButton.icon(onPressed:busy?null:_importPack,icon:const Icon(Icons.file_download_outlined),label:Text(busy?'Importing...':'Import shared pack')),const SizedBox(width:10),FilledButton.icon(onPressed:_shareProject,icon:const Icon(Icons.folder_copy_rounded),label:const Text('Share project'))]),
      const SizedBox(height:18),
      Container(width:double.infinity,padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:const Color(0xFF10131A),border:Border.all(color:const Color(0xFF292E3A)),borderRadius:BorderRadius.circular(12)),child:Row(children:[const Icon(Icons.privacy_tip_outlined,color:Color(0xFF22D3EE)),const SizedBox(width:10),const Expanded(child:Text('Only footage with an original source URL can be shared. Local imports and local PC paths are excluded.',style:TextStyle(color:Color(0xFFB6BDCA)))),Text('${items.length} shareable',style:const TextStyle(fontWeight:FontWeight.w700))])),
      const SizedBox(height:16),
      Row(children:[Checkbox(value:items.isNotEmpty&&selected.length==items.length,onChanged:items.isEmpty?null:(v)=>setState((){selected.clear();if(v==true)selected.addAll(items.map((e)=>e.id));})),const Text('Select all'),const SizedBox(width:12),Text('${selected.length} selected',style:const TextStyle(color:Color(0xFF8F96A6))),const Spacer(),FilledButton.icon(onPressed:selected.isEmpty?null:()=>_writePack('Footage Share',items.where((e)=>selected.contains(e.id)).toList()),icon:const Icon(Icons.ios_share_rounded),label:const Text('Share selected'))]),
      const SizedBox(height:12),
      Expanded(child:items.isEmpty?const Center(child:Text('No shareable footage yet.',style:TextStyle(color:Color(0xFF858C9C)))):ListView.separated(itemCount:items.length,separatorBuilder:(_,__)=>const SizedBox(height:8),itemBuilder:(_,i){final e=items[i];final on=selected.contains(e.id);return Card(child:CheckboxListTile(value:on,onChanged:(v)=>setState((){if(v==true)selected.add(e.id);else selected.remove(e.id);}),secondary:SizedBox(width:78,height:48,child:ClipRRect(borderRadius:BorderRadius.circular(7),child:e.thumbnail==null?const ColoredBox(color:Color(0xFF0E1117),child:Icon(Icons.movie_rounded)):_thumbImage(e.thumbnail!,fallbackSize:24))),title:Text(e.title,maxLines:1,overflow:TextOverflow.ellipsis),subtitle:Text('${e.projectName} • ${e.collection??'Unsorted'} • ${e.formatLabel}',maxLines:1,overflow:TextOverflow.ellipsis)));}))
    ]));
  });
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override State<SettingsPage> createState()=>_SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage> {
  String? path;
  String? ytDlpPath;
  String? defaultDownloadPath;
  String proxyMode='system';
  String youtubeAuthMode='none';
  String youtubeBrowser='chrome';
  String? youtubeCookiesFile;
  final proxyHostController=TextEditingController();
  final proxyPortController=TextEditingController();
  bool focusChromeLinks = true;
  bool checking=false;
  bool checkingYtDlp=false;
  bool? valid;
  bool? validYtDlp;
  @override void initState(){super.initState();_load();_loadFocusPreference();}
  Future<void> _loadFocusPreference() async { final prefs = await SharedPreferences.getInstance(); if (mounted) setState(() => focusChromeLinks = prefs.getBool(FootageFlowWindowFocus.preferenceKey) ?? true); }
  Future<void> _load() async { final p=await AppSettingsStore.loadFfmpegPath(); final y=await AppSettingsStore.loadYtDlpPath(); final d=await AppSettingsStore.loadDefaultDownloadPath(); final pm=await AppSettingsStore.loadProxyMode(); final pu=await AppSettingsStore.loadProxyUrl(); final yam=await AppSettingsStore.loadYoutubeAuthMode(); final yab=await AppSettingsStore.loadYoutubeBrowser(); final ycf=await AppSettingsStore.loadYoutubeCookiesFile(); if(!mounted)return; setState((){path=p;ytDlpPath=y;defaultDownloadPath=d;proxyMode=pm;youtubeAuthMode=yam;youtubeBrowser=yab;youtubeCookiesFile=ycf; final raw=(pu??'').trim(); if(raw.isNotEmpty){ try { final normalized=raw.contains('://')?raw:'http://$raw'; final u=Uri.parse(normalized); proxyHostController.text=u.host.isNotEmpty?u.host:raw.split(':').first; proxyPortController.text=u.hasPort?u.port.toString():(raw.contains(':')?raw.split(':').last:''); } catch(_){ final parts=raw.replaceFirst(RegExp(r'^https?://'), '').split(':'); proxyHostController.text=parts.isNotEmpty?parts.first:''; proxyPortController.text=parts.length>1?parts.last:''; } }}); if(p!=null) await _check(p); if(y!=null) await _checkYtDlp(y); }
  Future<void> _check(String p) async { setState(()=>checking=true); final ok=await DownloaderEngine.validateFfmpeg(p); if(mounted)setState((){checking=false;valid=ok;}); }
  Future<void> _browse() async {
    final picked=await FilePicker.platform.pickFiles(dialogTitle:'Choose ffmpeg.exe',type:FileType.custom,allowedExtensions:['exe']);
    final p=picked?.files.single.path; if(p==null)return;
    if(File(p).uri.pathSegments.last.toLowerCase()!='ffmpeg.exe'){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Please choose ffmpeg.exe.')));return;}
    final ok=await DownloaderEngine.validateFfmpeg(p);
    if(!ok){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('This file is not a valid FFmpeg executable.')));return;}
    await AppSettingsStore.saveFfmpegPath(p); DownloaderEngine.configuredFfmpegPath=p;
    if(mounted)setState((){path=p;valid=true;});
  }
  Future<void> _clear() async { await AppSettingsStore.saveFfmpegPath(null); DownloaderEngine.configuredFfmpegPath=null; if(mounted)setState((){path=null;valid=null;}); }
  Future<void> _checkYtDlp(String p) async { setState(()=>checkingYtDlp=true); final ok=await DownloaderEngine.validateYtDlp(p); if(mounted)setState((){checkingYtDlp=false;validYtDlp=ok;}); }
  Future<void> _browseYtDlp() async {
    final picked=await FilePicker.platform.pickFiles(dialogTitle:'Choose yt-dlp.exe',type:FileType.custom,allowedExtensions:['exe']);
    final p=picked?.files.single.path; if(p==null)return;
    if(File(p).uri.pathSegments.last.toLowerCase()!='yt-dlp.exe'){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Please choose yt-dlp.exe.')));return;}
    final ok=await DownloaderEngine.validateYtDlp(p);
    if(!ok){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('This file is not a valid yt-dlp executable.')));return;}
    await AppSettingsStore.saveYtDlpPath(p); DownloaderEngine.configuredYtDlpPath=p;
    if(mounted)setState((){ytDlpPath=p;validYtDlp=true;});
  }
  Future<void> _clearYtDlp() async { await AppSettingsStore.saveYtDlpPath(null); DownloaderEngine.configuredYtDlpPath=null; if(mounted)setState((){ytDlpPath=null;validYtDlp=null;}); }
  Future<void> _openExternalUrl(String url) async {
    try {
      await Process.start('cmd', ['/c', 'start', '', url], runInShell: true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the download page.')));
      }
    }
  }

  Future<void> _browseYoutubeCookies() async { final picked=await FilePicker.platform.pickFiles(dialogTitle:'Choose YouTube cookies.txt',type:FileType.custom,allowedExtensions:['txt']); final p=picked?.files.single.path; if(p==null)return; setState(()=>youtubeCookiesFile=p); await AppSettingsStore.saveYoutubeAuth('file',youtubeBrowser,p); }
  Future<void> _saveYoutubeAuth() async { if(youtubeAuthMode=='file'&&(youtubeCookiesFile==null||!File(youtubeCookiesFile!).existsSync())){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Choose a valid cookies.txt file first.')));return;} await AppSettingsStore.saveYoutubeAuth(youtubeAuthMode,youtubeBrowser,youtubeCookiesFile); if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('YouTube authentication settings saved.'))); }

  Future<void> _browseDefaultDownload() async { final picked=await FilePicker.platform.getDirectoryPath(dialogTitle:'Choose default download folder'); if(picked==null)return; await AppSettingsStore.saveDefaultDownloadPath(picked); if(mounted)setState(()=>defaultDownloadPath=picked); }
  Future<void> _resetDefaultDownload() async { await AppSettingsStore.saveDefaultDownloadPath(null); if(mounted)setState(()=>defaultDownloadPath=null); }
  Future<void> _saveProxy() async {
    String? v;
    if(proxyMode=='custom'){
      final host=proxyHostController.text.trim();
      final port=proxyPortController.text.trim();
      if(host.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Enter an IP address or host, for example 127.0.0.1')));return;}
      final portNumber=int.tryParse(port);
      if(portNumber==null || portNumber<1 || portNumber>65535){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Enter a valid port between 1 and 65535.')));return;}
      v='http://$host:$portNumber';
    }
    await AppSettingsStore.saveProxy(proxyMode, v);
    if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Network settings saved.')));
  }
  @override void dispose(){proxyHostController.dispose();proxyPortController.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>SingleChildScrollView(padding:const EdgeInsets.all(28),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Card(child: ListTile(leading: const Icon(Icons.extension_rounded), title: const Text('Chrome extension'),
        subtitle: const Text('Pairing is approved inside FootageFlow. No token entry required.'),
        trailing: TextButton(onPressed: () async { await FootageFlowChromeBridge.revokeAll(); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chrome extension connections reset.'))); }, child: const Text('Disconnect all')))),

    Card(child: SwitchListTile(
      secondary: const Icon(Icons.open_in_new_rounded),
      title: const Text('Focus FootageFlow when receiving links'),
      subtitle: const Text('Bring the Windows window forward when Chrome sends a link.'),
      value: focusChromeLinks,
      onChanged: (enabled) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(FootageFlowWindowFocus.preferenceKey, enabled);
        if (mounted) setState(() => focusChromeLinks = enabled);
      },
    )),
    const SizedBox(height: 12),
    Container(constraints: const BoxConstraints(maxWidth:760), padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFF13161D), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF292E3A))),
      child: Row(children: [
        const Icon(Icons.language_rounded, color: Color(0xFF22D3EE)), const SizedBox(width:12),
        const Expanded(child: Text('Language')),
        DropdownButton<String>(value: footageFlowLanguage.value,
          items: const [DropdownMenuItem(value:'en',child: Text('English')), DropdownMenuItem(value:'fa',child: Text('Persian'))],
          onChanged: (v) async { if (v == null) return; final prefs = await SharedPreferences.getInstance(); await prefs.setString('footageflow_language_v1', v); footageFlowLanguage.value = v; if (mounted) setState(() {}); },
        ),
      ])),
    const SizedBox(height:18),

    const Text('Settings',style:TextStyle(fontSize:28,fontWeight:FontWeight.w800)),const SizedBox(height:6),const Text('Configure external tools used by FootageFlow.',style:TextStyle(color:Color(0xFF8F96A6))),const SizedBox(height:26),
    Container(constraints:const BoxConstraints(maxWidth:760),padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:const Color(0xFF13161D),borderRadius:BorderRadius.circular(16),border:Border.all(color:const Color(0xFF242833))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Row(children:[Icon(Icons.video_settings_rounded,color:Color(0xFF8B5CF6)),SizedBox(width:10),Text('FFmpeg',style:TextStyle(fontSize:18,fontWeight:FontWeight.w700))]),const SizedBox(height:8),
      const Text('FFmpeg is not downloaded by the app. Choose an existing ffmpeg.exe on this PC.',style:TextStyle(color:Color(0xFF8F96A6),height:1.4)),const SizedBox(height:18),
      Container(width:double.infinity,padding:const EdgeInsets.symmetric(horizontal:14,vertical:13),decoration:BoxDecoration(color:const Color(0xFF10131A),borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFF292E3A))),child:Text(path??'No FFmpeg selected',maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(color:path==null?const Color(0xFF777E8E):Colors.white))),const SizedBox(height:12),
      Row(children:[FilledButton.icon(onPressed:_browse,icon:const Icon(Icons.folder_open_rounded),label:Text(path==null?'Choose ffmpeg.exe':'Change path')),if(path!=null)...[const SizedBox(width:10),OutlinedButton(onPressed:_clear,child:const Text('Clear'))],const Spacer(),if(checking)const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2))else if(valid==true)const Row(children:[Icon(Icons.check_circle_rounded,color:Color(0xFF4ADE80),size:19),SizedBox(width:6),Text('FFmpeg detected',style:TextStyle(color:Color(0xFF4ADE80)))])else if(path!=null)const Row(children:[Icon(Icons.error_outline_rounded,color:Color(0xFFFF6B6B),size:19),SizedBox(width:6),Text('FFmpeg not found',style:TextStyle(color:Color(0xFFFF6B6B)))])]),
      const SizedBox(height:10),
      TextButton.icon(onPressed:()=>_openExternalUrl('https://ffmpeg.org/download.html'),icon:const Icon(Icons.open_in_new_rounded,size:18),label:const Text('Download FFmpeg')),
      if(path!=null)...[const SizedBox(height:10),Text(File('${File(path!).parent.path}${Platform.pathSeparator}ffprobe.exe').existsSync()?'ffprobe.exe detected in the same folder.':'ffprobe.exe was not found in the same folder (optional for most downloads).',style:const TextStyle(fontSize:12,color:Color(0xFF8F96A6)))]
    ])),
    const SizedBox(height:18),
    Container(constraints:const BoxConstraints(maxWidth:760),padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:const Color(0xFF13161D),borderRadius:BorderRadius.circular(16),border:Border.all(color:const Color(0xFF242833))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Row(children:[Icon(Icons.travel_explore_rounded,color:Color(0xFF22D3EE)),SizedBox(width:10),Text('yt-dlp',style:TextStyle(fontSize:18,fontWeight:FontWeight.w700))]),const SizedBox(height:8),
      const Text('yt-dlp is not downloaded by the app. Choose an existing yt-dlp.exe on this PC.',style:TextStyle(color:Color(0xFF8F96A6),height:1.4)),const SizedBox(height:18),
      Container(width:double.infinity,padding:const EdgeInsets.symmetric(horizontal:14,vertical:13),decoration:BoxDecoration(color:const Color(0xFF10131A),borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFF292E3A))),child:Text(ytDlpPath??'No yt-dlp selected',maxLines:2,overflow:TextOverflow.ellipsis,style:TextStyle(color:ytDlpPath==null?const Color(0xFF777E8E):Colors.white))),const SizedBox(height:12),
      Row(children:[FilledButton.icon(onPressed:_browseYtDlp,icon:const Icon(Icons.folder_open_rounded),label:Text(ytDlpPath==null?'Choose yt-dlp.exe':'Change path')),if(ytDlpPath!=null)...[const SizedBox(width:10),OutlinedButton(onPressed:_clearYtDlp,child:const Text('Clear'))],const Spacer(),if(checkingYtDlp)const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2))else if(validYtDlp==true)const Row(children:[Icon(Icons.check_circle_rounded,color:Color(0xFF4ADE80),size:19),SizedBox(width:6),Text('yt-dlp detected',style:TextStyle(color:Color(0xFF4ADE80)))])else if(ytDlpPath!=null)const Row(children:[Icon(Icons.error_outline_rounded,color:Color(0xFFFF6B6B),size:19),SizedBox(width:6),Text('yt-dlp not found',style:TextStyle(color:Color(0xFFFF6B6B)))])]),
      const SizedBox(height:10),
      TextButton.icon(onPressed:()=>_openExternalUrl('https://github.com/yt-dlp/yt-dlp/releases/latest'),icon:const Icon(Icons.open_in_new_rounded,size:18),label:const Text('Download yt-dlp')),
    ])),
    const SizedBox(height:18),
    Container(constraints:const BoxConstraints(maxWidth:760),padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:const Color(0xFF13161D),borderRadius:BorderRadius.circular(16),border:Border.all(color:const Color(0xFF242833))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Row(children:[Icon(Icons.account_circle_outlined,color:Color(0xFFFF6B6B)),SizedBox(width:10),Text('YouTube Authentication',style:TextStyle(fontSize:18,fontWeight:FontWeight.w700))]),const SizedBox(height:8),
      const Text('Use your own local browser session when YouTube asks to confirm you are not a bot. FootageFlow never uploads or bundles your cookies.',style:TextStyle(color:Color(0xFF8F96A6),height:1.4)),const SizedBox(height:16),
      SegmentedButton<String>(segments:const [ButtonSegment(value:'none',label:Text('Off')),ButtonSegment(value:'browser',label:Text('Browser cookies')),ButtonSegment(value:'file',label:Text('cookies.txt'))],selected:{youtubeAuthMode},onSelectionChanged:(v)=>setState(()=>youtubeAuthMode=v.first)),
      if(youtubeAuthMode=='browser')...[const SizedBox(height:14),DropdownButtonFormField<String>(initialValue:youtubeBrowser,decoration:InputDecoration(labelText:ffTranslate('Browser')),items:const ['chrome','edge','firefox','brave','opera','vivaldi'].map((e)=>DropdownMenuItem(value:e,child:Text(e[0].toUpperCase()+e.substring(1)))).toList(),onChanged:(v){if(v!=null)setState(()=>youtubeBrowser=v);}),const SizedBox(height:8),const Text('You must be signed in to YouTube in the selected browser.',style:TextStyle(fontSize:12,color:Color(0xFF8F96A6)))],
      if(youtubeAuthMode=='file')...[const SizedBox(height:14),Container(width:double.infinity,padding:const EdgeInsets.symmetric(horizontal:14,vertical:13),decoration:BoxDecoration(color:const Color(0xFF10131A),borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFF292E3A))),child:Text(youtubeCookiesFile??'No cookies.txt selected',maxLines:2,overflow:TextOverflow.ellipsis)),const SizedBox(height:10),OutlinedButton.icon(onPressed:_browseYoutubeCookies,icon:const Icon(Icons.folder_open_rounded),label:const Text('Choose cookies.txt'))],
      const SizedBox(height:14),FilledButton.icon(onPressed:_saveYoutubeAuth,icon:const Icon(Icons.save_rounded),label:const Text('Save YouTube authentication')),
      const SizedBox(height:8),const Text('Security: cookies stay on this PC. Never commit cookies.txt to GitHub or share it with anyone.',style:TextStyle(fontSize:12,color:Color(0xFFFFB4B4)))
    ])),
    const SizedBox(height:18),
    Container(constraints:const BoxConstraints(maxWidth:760),padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:const Color(0xFF13161D),borderRadius:BorderRadius.circular(16),border:Border.all(color:const Color(0xFF242833))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Row(children:[Icon(Icons.lan_rounded,color:Color(0xFF8B5CF6)),SizedBox(width:10),Text('Network / Proxy',style:TextStyle(fontSize:18,fontWeight:FontWeight.w700))]),const SizedBox(height:8),
      const Text('Use the same proxy for yt-dlp and FFmpeg clip streams. Mixed ports such as 127.0.0.1:10808 are supported.',style:TextStyle(color:Color(0xFF8F96A6),height:1.4)),const SizedBox(height:16),
      SegmentedButton<String>(segments:const [ButtonSegment(value:'system',label:Text('System / Auto'),icon:Icon(Icons.auto_awesome_rounded)),ButtonSegment(value:'custom',label:Text('Custom'),icon:Icon(Icons.tune_rounded)),ButtonSegment(value:'off',label:Text('Off'),icon:Icon(Icons.block_rounded))],selected:{proxyMode},onSelectionChanged:(v)=>setState(()=>proxyMode=v.first)),
      if(proxyMode=='custom')...[
        const SizedBox(height:14),
        Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Expanded(flex:3,child:TextField(controller:proxyHostController,decoration:InputDecoration(labelText:ffTranslate('IP / Host'),hintText:ffTranslate('127.0.0.1')))),
          const SizedBox(width:12),
          SizedBox(width:170,child:TextField(controller:proxyPortController,keyboardType:TextInputType.number,inputFormatters:[FilteringTextInputFormatter.digitsOnly],decoration:InputDecoration(labelText:ffTranslate('Port'),hintText:ffTranslate('10808')))),
        ]),
        const SizedBox(height:8),
        const Text('Example: 127.0.0.1 + 10808 → http://127.0.0.1:10808',style:TextStyle(fontSize:12,color:Color(0xFF8F96A6))),
      ],
      const SizedBox(height:14),Row(children:[FilledButton.icon(onPressed:_saveProxy,icon:const Icon(Icons.save_rounded),label:const Text('Save network settings')),const SizedBox(width:12),Expanded(child:Text(proxyMode=='system'?'Uses Windows/environment proxy automatically.':proxyMode=='off'?'Ignores proxy environment for downloads.':'Custom proxy is passed to yt-dlp and the FFmpeg process environment.',style:const TextStyle(fontSize:12,color:Color(0xFF8F96A6))))])
    ])),
    const SizedBox(height:18),
    Container(constraints:const BoxConstraints(maxWidth:760),padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:const Color(0xFF13161D),borderRadius:BorderRadius.circular(16),border:Border.all(color:const Color(0xFF242833))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Row(children:[Icon(Icons.download_for_offline_rounded,color:Color(0xFF22D3EE)),SizedBox(width:10),Text('Default download folder',style:TextStyle(fontSize:18,fontWeight:FontWeight.w700))]),const SizedBox(height:8),
      const Text('Used whenever you download without selecting a project.',style:TextStyle(color:Color(0xFF8F96A6))),const SizedBox(height:16),
      Container(width:double.infinity,padding:const EdgeInsets.symmetric(horizontal:14,vertical:13),decoration:BoxDecoration(color:const Color(0xFF10131A),borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xFF292E3A))),child:Text(defaultDownloadPath??r'Windows Downloads\Footage Collector',maxLines:2,overflow:TextOverflow.ellipsis)),const SizedBox(height:12),
      Row(children:[FilledButton.icon(onPressed:_browseDefaultDownload,icon:const Icon(Icons.folder_open_rounded),label:Text(defaultDownloadPath==null?'Choose folder':'Change folder')),if(defaultDownloadPath!=null)...[const SizedBox(width:10),OutlinedButton(onPressed:_resetDefaultDownload,child:const Text('Use Windows default'))]])
    ])),
    const SizedBox(height:18),
    Container(constraints:const BoxConstraints(maxWidth:760),padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:const Color(0xFF13161D),borderRadius:BorderRadius.circular(16),border:Border.all(color:const Color(0xFF242833))),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[Icon(Icons.info_outline_rounded,color:Color(0xFF8B5CF6)),SizedBox(width:10),Text('About FootageFlow',style:TextStyle(fontSize:18,fontWeight:FontWeight.w700))]),
      SizedBox(height:16),
      Text('FootageFlow',style:TextStyle(fontSize:22,fontWeight:FontWeight.w800)),
      SizedBox(height:4),
      Text('Version 7.22.22',style:TextStyle(color:Color(0xFF8F96A6))),
      SizedBox(height:18),
      Divider(color:Color(0xFF292E3A)),
      SizedBox(height:14),
      Text('Created by PHAsE',style:TextStyle(fontSize:15,fontWeight:FontWeight.w700)),
      SizedBox(height:5),
      SelectableText('Telegram: @PHAsEcut',style:TextStyle(color:Color(0xFF22D3EE))),
      SizedBox(height:18),
      Text('Special Thanks',style:TextStyle(fontSize:15,fontWeight:FontWeight.w700)),
      SizedBox(height:5),
      Text('TOKITO — @The_Tokito',style:TextStyle(color:Color(0xFF22D3EE))),
      SizedBox(height:4),
      Text('For support and contribution to the project.',style:TextStyle(color:Color(0xFF8F96A6),height:1.4)),
    ]))
  ]));
}

class PlaceholderPage extends StatelessWidget { final String title; final IconData icon; const PlaceholderPage({super.key, required this.title, required this.icon}); @override Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 58, color: Colors.white24), const SizedBox(height: 14), Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)), const SizedBox(height: 6), const Text('Coming in the next step', style: TextStyle(color: Color(0xFF858C9C)))])); }
