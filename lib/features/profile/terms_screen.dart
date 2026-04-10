import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_state.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppState().translate("Terms & Conditions", "Shuruudaha & Xaaladaha", ar: "الشروط والأحكام", de: "Allgemeine Geschäftsbedingungen", et: "Kasutustingimused"), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${AppState().translate("Last updated", "Markii u dambeysay ee la cusboonaysiiyay", ar: "آخر تحديث", de: "Zuletzt aktualisiert", et: "Viimati uuendatud")}: Oct 2023", 
              style: const TextStyle(color: AppColors.grey)
            ),
            const SizedBox(height: 24),
            _buildSection(
              AppState().translate("1. Acceptance of Terms", "1. Aqbalaadda Shuruudaha", ar: "1. الموافقة على الشروط", de: "1. Annahme der Bedingungen", et: "1. Tingimustega nõustumine"), 
              AppState().translate(
                "By using MurtaaxPay, you agree to comply with these terms. If you do not agree, please stop using the service.", 
                "Markaad isticmaasho MurtaaxPay, waxaad ku raacaysaa inaad u hoggaansanto shuruudahan. Haddii aadan ku raacin, fadlan jooji isticmaalka adeegga.", 
                ar: "باستخدام MurtaaxPay، فإنك توافق على الالتزام بهذه الشروط. إذا كنت لا توافق، يرجى التوقف عن استخدام الخدمة.", 
                de: "Durch die Nutzung von MurtaaxPay erklären Sie sich mit diesen Bedingungen einverstanden. Wenn Sie nicht einverstanden sind, stellen Sie bitte die Nutzung des Dienstes ein.",
                et: "Kasutades MurtaaxPayd, nõustute järgima neid tingimusi. Kui te ei nõustu, lõpetage teenuse kasutamine."
              )
            ),
            _buildSection(
              AppState().translate("2. User Verification", "2. Xaqiijinta Isticmaalaha", ar: "2. التحقق من المستخدم", de: "2. Benutzerverifizierung", et: "2. Kasutaja kinnitamine"), 
              AppState().translate(
                "MurtaaxPay requires all users to provide valid identity documentation (KYC) to prevent fraud and comply with international regulations.", 
                "MurtaaxPay wuxuu u baahan yahay dhammaan isticmaaleyaasha inay bixiyaan dukumiintiyo aqoonsi oo ansax ah (KYC) si looga hortago khiyaanada loona hoggaansamo xeerarka caalamiga ah.", 
                ar: "تطلب MurtaaxPay من جميع المستخدمين تقديم وثائق هوية صالحة (KYC) لمنع الاحتيال والامتثال للوائح الدولية.", 
                de: "MurtaaxPay verlangt von allen Benutzern die Bereitstellung gültiger Identitätsdokumente (KYC), um Betrug zu verhindern und internationale Vorschriften einzuhalten.",
                et: "MurtaaxPay nõuab kõigilt kasutajatelt kehtiva isikut tõendava dokumendi (KYC) esitamist pettuste vältimiseks ja rahvusvaheliste eeskirjade täitmiseks."
              )
            ),
            _buildSection(
              AppState().translate("3. Transaction Fees", "3. Kharashka Macaamilka", ar: "3. رسوم المعاملات", de: "3. Transaktionsgebühren", et: "3. Tehingutasud"), 
              AppState().translate(
                "Transaction fees are displayed before every transfer. Fees may vary depending on the destination and method of payment.", 
                "Kharashka macaamilka waxaa la soo bandhigaa ka hor wareejin kasta. Kharashyadu way kala duwaan karaan iyadoo ku xiran meesha loo dirayo iyo habka lacag bixinta.", 
                ar: "يتم عرض رسوم المعاملات قبل كل عملية تحويل. قد تختلف الرسوم حسب الوجهة وطريقة الدفع.", 
                de: "Transaktionsgebühren werden vor jeder Überweisung angezeigt. Die Gebühren können je nach Bestimmungsort und Zahlungsmethode variieren.",
                et: "Tehingutasud kuvatakse enne iga ülekannet. Tasud võivad erineda sõltuvalt sihtkohast ja makseviisist."
              )
            ),
            _buildSection(
              AppState().translate("4. Privacy Policy", "4. Siyaasadda Khaaska ah", ar: "4. سياسة الخصوصية", de: "4. Datenschutzerklärung", et: "4. Privaatsuspoliitika"), 
              AppState().translate(
                "We value your privacy. Your biometric data (FaceID/Fingerprint) is stored on your device only and is never transmitted to our servers.", 
                "Waxaan qiimeynaa sirtaada. Xogtaada biometric-ga ah (FaceID/Faraha) waxaa lagu kaydiyaa qalabkaaga oo kaliya weligoodna looma gudbiyo server-yadayada.", 
                ar: "نحن نقدر خصوصيتك. يتم تخزين بياناتك الحيوية (FaceID / بصمة الإصبع) على جهازك فقط ولا يتم نقلها أبداً إلى خوادمنا.", 
                de: "Wir schätzen Ihre Privatsphäre. Ihre biometrischen Daten (FaceID/Fingerabdruck) werden nur auf Ihrem Gerät gespeichert und niemals an unsere Server übertragen.",
                et: "Väärtustame teie privaatsust. Teie biomeetrilised andmed (FaceID/sõrmejälg) salvestatakse ainult teie seadmesse ja neid ei edastata kunagi meie serveritesse."
              )
            ),
            _buildSection(
              AppState().translate("5. Limitation of Liability", "5. Xaddididda Mas'uuliyadda", ar: "5. تحديد المسؤولية", de: "5. Haftungsbeschränkung", et: "5. Vastutuse piirang"), 
              AppState().translate(
                "MurtaaxPay is not responsible for any delays caused by intermediary banks or mobile network operators.", 
                "MurtaaxPay mas'uul kama aha dib u dhacyada ay keento bangiyada dhex-dhexaadka ah ama shirkadaha isgaarsiinta moobaylka.", 
                ar: "MurtaaxPay ليست مسؤولة عن أي تأخير ناجم عن البنوك الوسيطة أو مشغلي شبكات الهاتف المحمول.", 
                de: "MurtaaxPay ist nicht verantwortlich für Verzögerungen, die durch zwischengeschaltete Banken oder Mobilfunkbetreiber verursacht werden.",
                et: "MurtaaxPay ei vastuta vahenduspankade või mobiilivõrgu operaatorite põhjustatud viivituste eest."
              )
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                "© 2026 MurtaaxPay. ${AppState().translate("All rights reserved.", "Xuquuqda oo dhan waa la dhowray.", ar: "جميع الحقوق محفوظة.", de: "Alle Rechte vorbehalten.", et: "Kõik õigused kaitstud.")}",
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
