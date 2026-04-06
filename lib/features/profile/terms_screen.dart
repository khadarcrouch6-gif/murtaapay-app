import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppState().translate("Terms & Conditions", "Shuruudaha & Xaaladaha", ar: "الشروط والأحكام", de: "Allgemeine Geschäftsbedingungen"), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${AppState().translate("Last updated", "Markii u dambeysay ee la cusboonaysiiyay", ar: "آخر تحديث", de: "Zuletzt aktualisiert")}: Oct 2023", 
              style: const TextStyle(color: AppColors.grey)
            ),
            const SizedBox(height: 24),
            _buildSection(
              AppState().translate("1. Acceptance of Terms", "1. Aqbalaadda Shuruudaha", ar: "1. الموافقة على الشروط", de: "1. Annahme der Bedingungen"), 
              AppState().translate(
                "By using MurtaaxPay, you agree to comply with these terms. If you do not agree, please stop using the service.", 
                "Markaad isticmaasho MurtaaxPay, waxaad ku raacaysaa inaad u hoggaansanto shuruudahan. Haddii aadan ku raacin, fadlan jooji isticmaalka adeegga.", 
                ar: "باستخدام MurtaaxPay، فإنك توافق على الالتزام بهذه الشروط. إذا كنت لا توافق، يرجى التوقف عن استخدام الخدمة.", 
                de: "Durch die Nutzung von MurtaaxPay erklären Sie sich mit diesen Bedingungen einverstanden. Wenn Sie nicht einverstanden sind, stellen Sie bitte die Nutzung des Dienstes ein."
              )
            ),
            _buildSection(
              AppState().translate("2. User Verification", "2. Xaqiijinta Isticmaalaha", ar: "2. التحقق من المستخدم", de: "2. Benutzerverifizierung"), 
              AppState().translate(
                "MurtaaxPay requires all users to provide valid identity documentation (KYC) to prevent fraud and comply with international regulations.", 
                "MurtaaxPay wuxuu u baahan yahay dhammaan isticmaaleyaasha inay bixiyaan dukumiintiyo aqoonsi oo ansax ah (KYC) si looga hortago khiyaanada loona hoggaansamo xeerarka caalamiga ah.", 
                ar: "تطلب MurtaaxPay من جميع المستخدمين تقديم وثائق هوية صالحة (KYC) لمنع الاحتيال والامتثال للوائح الدولية.", 
                de: "MurtaaxPay verlangt von allen Benutzern die Bereitstellung gültiger Identitätsdokumente (KYC), um Betrug zu verhindern und internationale Vorschriften einzuhalten."
              )
            ),
            _buildSection(
              AppState().translate("3. Transaction Fees", "3. Kharashka Macaamilka", ar: "3. رسوم المعاملات", de: "3. Transaktionsgebühren"), 
              AppState().translate(
                "Transaction fees are displayed before every transfer. Fees may vary depending on the destination and method of payment.", 
                "Kharashka macaamilka waxaa la soo bandhigaa ka hor wareejin kasta. Kharashyadu way kala duwanaan karaan iyadoo ku xiran meesha loo dirayo iyo habka lacag bixinta.", 
                ar: "يتم عرض رسوم المعاملات قبل كل عملية تحويل. قد تختلف الرسوم حسب الوجهة وطريقة الدفع.", 
                de: "Transaktionsgebühren werden vor jeder Überweisung angezeigt. Die Gebühren können je nach Bestimmungsort und Zahlungsmethode variieren."
              )
            ),
            _buildSection(
              AppState().translate("4. Privacy Policy", "4. Siyaasadda Khaaska ah", ar: "4. سياسة الخصوصية", de: "4. Datenschutzerklärung"), 
              AppState().translate(
                "We value your privacy. Your biometric data (FaceID/Fingerprint) is stored on your device only and is never transmitted to our servers.", 
                "Waxaan qiimeynaa sirtaada. Xogtaada biometric-ga ah (FaceID/Faraha) waxaa lagu kaydiyaa qalabkaaga oo kaliya weligoodna looma gudbiyo server-yadayada.", 
                ar: "نحن نقدر خصوصيتك. يتم تخزين بياناتك الحيوية (FaceID / بصمة الإصبع) على جهازك فقط ولا يتم نقلها أبداً إلى خوادمنا.", 
                de: "Wir schätzen Ihre Privatsphäre. Ihre biometrischen Daten (FaceID/Fingerabdruck) werden nur auf Ihrem Gerät gespeichert und niemals an unsere Server übertragen."
              )
            ),
            _buildSection(
              AppState().translate("5. Limitation of Liability", "5. Xaddididda Mas'uuliyadda", ar: "5. تحديد المسؤولية", de: "5. Haftungsbeschränkung"), 
              AppState().translate(
                "MurtaaxPay is not responsible for any delays caused by intermediary banks or mobile network operators.", 
                "MurtaaxPay mas'uul kama aha dib u dhacyada ay keento bangiyada dhex-dhexaadka ah ama shirkadaha isgaarsiinta moobaylka.", 
                ar: "MurtaaxPay ليست مسؤولة عن أي تأخير ناجم عن البنوك الوسيطة أو مشغلي شبكات الهاتف المحمول.", 
                de: "MurtaaxPay ist nicht verantwortlich für Verzögerungen, die durch zwischengeschaltete Banken oder Mobilfunkbetreiber verursacht werden."
              )
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                "© 2023 MurtaaxPay. ${AppState().translate("All rights reserved.", "Xuquuqda oo dhan waa la dhowray.", ar: "جميع الحقوق محفوظة.", de: "Alle Rechte vorbehalten.")}",
                style: const TextStyle(color: AppColors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
