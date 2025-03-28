//
//  AlertPrivacyPolice.swift
//  Platforma
//
//  Created by Daniil Razbitski on 03/12/2024.
//

import SwiftUI

struct AlertPrivacyPolice: View {
    // Binding variable to control the visibility from the parent view
    @Binding var show: Bool

    var infoTextAlert: String?
    
    var pageName: String? = ""
    
    var cnacelaction: (() -> Void)?
    var mainAction: (() -> Void)?
    
    @State private var notificationStatus: UNAuthorizationStatus?

    @State var positiveButtonText: String = "info_message.alert_turn_on_notification"
    
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        VStack(spacing: 0) {
            
            HStack(alignment: .center, spacing: 0) {
                    Text("additional_element.privacy_policy")
                        .foregroundStyle(Color.white)
                        .font(.custom("Montserrat-Medium", size: 20))

                Spacer()
                Button {
                    show = false
                } label: {
                    Image("cross-blue")
//                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 23, height: 23)
                        .foregroundColor(Color.privacyPolicyCloseButton)
                }
            }
            .padding(.bottom, 10)
            
            ScrollView {
                VStack(spacing: 0) {
                    Text(LocalizedStringKey("privacy_policy_translate"))
//                    Text(privacyPolicyMultylineText)
                        .foregroundStyle(Color.white)
                        .font(.custom("Montserrat-Regular", size: 16))
                        .padding(.bottom, 20)
                    
                    Button {
                        show = false
                    } label: {
                        HStack(spacing: 0) {
                            Spacer()
                            
                            Text("OK")
                                .font(.custom("Montserrat-Medium", size: 16))
                                .foregroundStyle(Color.white)

                            Spacer()
                        }
                        .padding([.top, .bottom], 15)
                        .padding([.leading, .trailing], 20)
                        .background(Color.privacyPolicyCloseButton) // Background color inside the border
//                        .background(Color.headerLogBackgr) // Background color inside the border
                        .foregroundColor(Color.white)  // Text color
                        .cornerRadius(100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Color.privacyPolicyCloseButton, lineWidth: 1)
                        )
                        .padding(.horizontal, 1)
                    }
                }
            }

        }
        .padding(.all, 20)
    }
    
    
    let privacyPolicyMultylineText: String = """
1. INFORMACJE OGÓLNE

Firma MIA CONSULT GROUP Sp. z o.o. szanuje prawo Użytkowników do prywatności oraz dba o bezpieczeństwo danych udostępnionych przez Użytkowników. Szczególnie przywiązuje wagę do poszanowania prywatności Użytkowników, których dane osobowe są przetwarzane zgodnie z ustawą z dnia 10 maja 2018 r. o ochronie danych osobowych, służąca stosowaniu rozporządzenia Parlamentu Europejskiego i Rady UE nr 2016/679 z dnia 27 kwietnia 2016 roku (ogólne rozporządzenie o ochronie danych – «RODO»). MIA CONSULT GROUP Sp. z o.o. dokłada szczególnej staranności w stosowaniu zabezpieczenia danych, stosując odpowiednie rozwiązania technologiczne zapobiegając ingerencji w prywatność Użytkowników osób trzecich.
Administratorem danych osobowych jest działająca pod nazwą domeną PLATFORMAPRO.COM firma: 
MIA CONSULT GROUP Sp. z o.o. z siedzibą w Warszawie, 02-963, przy ul. Zygmunta Vogla 28/02 wpisanej do Krajowego Rejestru Sądowego pod numerem KRS 0000854891, o kapitale zakładowym 100 000 zł, NIP 1133018235, REGON 386780510;
Dane osobowe przetwarzane są w celu realizacji zamówień, usług świadczonych przez MIA CONSULT GROUP Sp. z o.o.
Dane uzyskane w procesie rejestracji będą wykorzystywane przez MIA CONSULT GROUP Sp. z o.o. jedynie do obsługi realizacji zamówień i nie są udostępniane osobom postronnym.
Administrator dokłada szczególnych starań w celu ochrony prywatności i informacji mu przekazanych, a dotyczących użytkowników strony internetowej.
Administrator z należytą starannością dobiera i stosuje odpowiednie środki techniczne, w tym o charakterze programistycznym i organizacyjnym, zapewniające ochronę przetwarzanych danych, w szczególności zabezpiecza dane przed ich udostępnieniem osobom nieupoważnionym, ujawnieniem, utraceniem i zniszczeniem, nieuprawnioną modyfikacją, jak również przed ich przetwarzaniem z naruszeniem obowiązujących przepisów prawa.
Administrator danych osobowych przetwarza tylko dane osób pełnoletnich.
W ramach korzystania przez Administratora z narzędzi wspierających jego bieżącą działalność udostępnianych np. przez firmę Google, Dane Osobowe Klienta mogą być przekazywane do państwa spoza Europejskiego Obszaru Gospodarczego, w szczególności do Stanów Zjednoczonych Ameryki (USA) lub innego państwa, w którym podmiot z nią współpracujący utrzymuje narzędzia służące do przetwarzania Danych Osobowych przy współpracy z Administratorem.
2. DANE ZBIERANE AUTOMATYCZNIE

Podczas wizyty na naszej stronie internetowej, automatycznie zbierane są dane dotyczące wizyty, na przykład adres IP, nazwa domeny, typ przeglądarki, typ systemu operacyjnego, itp.
Dane osobowe są przetwarzane zgodnie z zasadami z art. 5 RODO tj. Dane zbierane automatycznie mogą być użyte do analizy zachowań użytkowników na naszej stronie internetowej, zbierania danych demograficznych o naszych użytkownikach, lub do personalizacji zawartości naszych stron internetowych. Dane te są zbierane automatycznie o każdym użytkowniku. Dane zbierane w trakcie korespondencji pomiędzy Tobą, a naszym serwisem będą wykorzystane wyłącznie w celu odpowiedzi na zapytanie.
3. HOSTING

Serwis jest hostowany (technicznie utrzymywany) na serwerach operatora: home.pl S.A.
1. Serwis jest hostowany (technicznie utrzymywany) na serwerach operatora: home.pl 
2. Dane rejestrowe firmy hostingowej: home.pl SA z siedzibą w Szczecinie, ul. Zbożowa 4 70-653 Szczecin, Zarejestrowana w Sądzie Rejonowym – Centrum w Szczecinie, XIII Wydział Gospodarczy Krajowego Rejestru Sądowego. Kapitał zakładowy w kwocie 1.294.000 złotych w całości opłacony, Nr KRS: 0000431335, REGON: 811158242 NIP: 852-21-03-252. 
3. Pod adresem https://home.pl możesz dowiedzieć się więcej o hostingu i sprawdzić politykę prywatności firmy hostingowej. 
4. Firma hostingowa: 
stosuje środki ochrony przed utratą danych (np. macierze dyskowe, regularne kopie bezpieczeństwa), 
stosuje adekwatne środki ochrony miejsc przetwarzania na wypadek pożaru (np. specjalne systemy gaśnicze), 
stosuje adekwatne środki ochrony systemów przetwarzania na wypadek nagłej awarii zasilania (np. podwójne tory zasilania, agregaty, systemy podtrzymania napięcia UPS), 
stosuje środki fizycznej ochrony dostępu do miejsc przetwarzania danych (np. kontrola dostępu, monitoring),
stosuje środki zapewnienia odpowiednich warunków środowiskowych dla serwerów jako elementów systemu przetwarzania danych (np. kontrola warunków środowiskowych, specjalistyczne systemy klimatyzacji), 
stosuje rozwiązania organizacyjne dla zapewnienia możliwie wysokiego stopnia ochrony i poufności (szkolenia, wewnętrzne regulaminy, polityki haseł itp.), 
powołała Inspektora Ochrony Danych
5. Firma hostingowa w celu zapewnienia niezawodności technicznej prowadzi logi na poziomie serwera. Zapisowi mogą podlegać: 
zasoby określone identyfikatorem URL (adresy żądanych zasobów – stron, plików), 
czas nadejścia zapytania, 
czas wysłania odpowiedzi, 
nazwę stacji klienta – identyfikacja realizowana przez protokół HTTP, 
informacje o błędach jakie nastąpiły przy realizacji transakcji HTTP, 
adres URL strony poprzednio odwiedzanej przez użytkownika (referer link) – w przypadku gdy przejście do Serwisu nastąpiło przez odnośnik, 
informacje o przeglądarce użytkownika, 
informacje o adresie IP, 
informacje diagnostyczne związane z procesem samodzielnego zamawiania usług poprzez rejestratory na stronie, 
informacje związane z obsługą poczty elektronicznej kierowanej do Operatora oraz wysyłanej przez Operatora.
4. W JAKI SPOSÓB WYKORZYSTUJEMY DANE. UDOSTĘPNIANIE DANYCH

Dane osobowe uzyskane w ramach procesu instalacji tzw. Ciasteczek mogą być wykorzystane do profilowania. Więcej informacji o ciasteczkach w Polityce Cookies.
Prawa w ochronie danych osobowych
Z uwagi na dobrowolny charakter podania swoich danych osobowych, masz prawo:
dostępu do swoich danych osobowych (art. 15 RODO)
sprostowania swoich danych osobowych (art. 16 RODO)
usunięcia swoich danych osobowych („prawo do bycia zapomnianym” – art. 17 RODO )
ograniczenia przetwarzania sowich danych osobowych (art. 18 RODO)
przenoszenia swoich danych osobowych (ar. 20 RODO )
do sprzeciwu (art. 21 RODO)
W przypadku stwierdzenia, że przetwarzanie danych osobowych narusza przepisy RODO, masz prawo wnieść skargę do Prezesa Urzędu Ochrony Danych Osobowych.
Jego strona internetowa dostępna jest pod tym adresem: https://uodo.gov.pl/ .
W każdym czasie zgoda na przetwarzanie danych osobowych może być cofnięta. Cofnięcie zgody na przetwarzanie danych nie ma wpływu na zgodność z prawem przetwarzania danych dokonanych przez Administratora na podstawie zgody przed jej cofnięciem.
Wszelkie dane osobowe Użytkowników przetwarzane będą wyłącznie zgodnie z celem, dla którego zostały zebrane. Przetwarzanie danych osobowych w celach marketingowych jest możliwe jedynie po wyrażeniu uprzedniej zgody przez Użytkownika na podstawie regulaminu.
Miejsca logowania i wprowadzania danych osobowych są chronione w warstwie transmisji (certyfikat SSL). Dzięki temu dane osobowe i dane logowania, wprowadzone na stronie, zostają zaszyfrowane w komputerze użytkownika i mogą być odczytane jedynie na docelowym serwerze.
Dane osobowe przetwarzane przez Administratora nie dłużej, niż jest to konieczne do wykonania związanych z nimi czynności określonych osobnymi przepisami (np. o prowadzeniu rachunkowości).
Dane osobowe mogą być przekazywane podmiotom, które technicznie realizują niektóre usługi. Dotyczy to w szczególności sytuacji, w której MIA CONSULT GROUP Sp. z o.o. przekazuje informacje o Użytkowniku podmiotowi będącemu operatorem rejestrowanej domeny internetowej, lub podmiotom współpracującym z MIA CONSULT GROUP Sp. z o.o. w zakresie rejestracji domeny internetowej, dostawcom systemów informatycznych oraz usług IT, firmom świadczącym usługi prawne, analityczne; operatorom pocztowym i kurierom; operatorom systemów płatności elektronicznych oraz bankom w zakresie realizacji płatności; organom uprawnionym do otrzymania danych osobowych Abonenta na podstawie przepisów prawa. W przypadku kontroli Generalnego Inspektoratu Ochrony Danych Osobowych, dane mogą zostać udostępnione pracownikom Inspektoratu zgodnie z ustawą o ochronie danych osobowych. 
Dane osobowe Użytkowników są przechowywane w bazie danych, w której zastosowano środki techniczne i organizacyjne zapewniające ochronę przetwarzanych danych, zgodne z wymaganiami określonymi w przepisach o ochronie danych osobowych.
Dane Osobowe Klienta mogą być przetwarzane również na podstawie:
Obowiązujących przepisów prawa – gdy przetwarzanie jest niezbędne do wypełnienia obowiązku prawnego ciążącego na Administratorze, np. gdy na bazie przepisów podatkowych lub rachunkowych Administrator rozlicza zawarte umowy (art. 6 ust. 1 lit. c) RODO);
Niezbędności do innych niż wymienione powyżej celów wynikających z prawnie uzasadnionych interesów realizowanych przez Administratora lub przez stronę trzecią, w szczególności do ustalenia, dochodzenia lub obrony roszczeń, prowadzenia korespondencji z Klientami.(art. 6 ust. 1 lit. f) RODO)
W przypadku naruszenia ochrony danych osobowych, Administrator bez zbędnej zwłoki, nie później niż w terminie 72 godzin po stwierdzeniu naruszenia – zgłasza je organowi nadzorczemu –(Prezesowi Urzędu Ochrony Danych Osobowych), chyba że jest mało prawdopodobne, by naruszenie to skutkowało ryzykiem naruszenia praw lub wolności osób fizycznych. Do zgłoszenia przekazanego organowi nadzorczemu po upływie 72 godzin, Administrator dołącza wyjaśnienie przyczyn opóźnienia. Jeżeli naruszenie ochrony danych osobowych może powodować wysokie ryzyko naruszenia praw lub wolności osób fizycznych, Administrator bez zbędnej zwłoki zawiadamia osobę, której dane dotyczą, o takim naruszeniu.

5. GOOGLE ANALYTICS

Niniejsza witryna internetowa korzysta z Google Analytics, usługi analizy oglądalności stron internetowych udostępnianej przez Google, Inc. (“Google”). Google Analytics używa “cookies”, czyli plików tekstowych umieszczanych na komputerze użytkownika w celu umożliwienia witrynie przeanalizowania sposobu, w jaki użytkownicy z niej korzystają. Informacje generowane przez cookie na temat korzystania z witryny przez użytkownika (włącznie z jego adresem IP) będą przekazywane spółce Google i przechowywane przez nią na serwerach w Stanach Zjednoczonych. 
Google będzie korzystała z tych informacji w celu oceny korzystania z witryny przez użytkownika, tworzenia raportów dotyczących ruchu na stronach dla operatorów witryn oraz świadczenia innych usług związanych z ruchem na witrynach internetowych i korzystaniem z internetu. Google może również przekazywać te informacje osobom trzecim, jeżeli będzie zobowiązana to uczynić na podstawie przepisów prawa lub w przypadku, gdy osoby te przetwarzają takie informacje w imieniu Google. Google nie będzie łączyła adresu IP użytkownika z żadnymi innymi danymi będącymi w jej posiadaniu. Użytkownik może zrezygnować z cookies wybierając odpowiednie ustawienia na przeglądarce, jednak należy pamiętać, że w takim przypadku korzystanie z wszystkich funkcji witryny może okazać się niemożliwe Korzystając z niniejszej witryny internetowej użytkownik wyraża zgodę na przetwarzanie przez Google dotyczących go danych w sposób i w celach określonych powyżej. 
Użytkownik który nie wyraża zgody na działanie systemu Google Analytics powinien zastosować blokadę plików cookies. 

6. HASŁA

Dane osobowe przetwarzają wyłącznie przeszkoleni pracownicy, którym MIA CONSULT GROUP Sp. z o.o. nadał stosowne upoważnienia.
Internetowy dostęp do usług jest możliwy poprzez stronę internetową, weryfikowany loginem i hasłem w trybie szyfrowanym.
Informacje o Twoim koncie na platformapro.com, nazwa użytkownika i profil klienta są chronione hasłem, dzięki czemu masz bezpieczny dostęp do logowania i edytowania swoich danych osobowych. Za bezpieczeństwo hasła odpowiada użytkownik.
Dostęp do konta platformapro.com chroniony jest unikalną nazwą użytkownika i hasłem, które znasz tylko Ty. Nasza strona wykorzystuje wewnętrzne procesy bezpieczeństwa, które szyfrują hasło klienta, aby chronić je przed ujawnieniem lub dostępem przez kogokolwiek innego niż Ty. Ani pracownicy Firmy, ani żaden z jej kontrahentów nie będzie prosić Cię o podanie hasła pocztą, e-mailem, telefonicznie lub w inny niespójny sposób.
Użytkownik ma prawo żądania dostępu do swoich danych osobowych, ich sprostowania, usunięcia lub ograniczenia przetwarzania, prawo do przeniesienia danych, wyrażenia sprzeciwu wobec przetwarzania danych oraz prawo do wniesienia skargi do organu nadzorczego.

7. ZMIANY NASZEJ POLITYKI PRYWATNOŚCI

Zastrzegamy sobie prawo zmiany powyższej polityki prywatności poprzez opublikowanie nowej polityki prywatności na tej stronie.

8. BEZPIECZEŃSTWO I DANE KONTAKTOWE

MIA CONSULT GROUP Sp. z o.o.  wykonuje cyklicznie kopie zapasowe serwisów www i poczty elektronicznej. Ponadto MIA CONSULT GROUP Sp. z o.o. stosuje między innymi zabezpieczenia antyspamowe oraz antywirusowe. Oprogramowanie i systemy bezpieczeństwa są na bieżąco aktualizowane.
Zapytania oraz wnioski, dotyczące zakresu przetwarzania danych osobowych, można przesyłać pocztą tradycyjną na adres: ul. Zygmunta Vogla 28/02, 02-963, Warszawa, oraz mailem na adres support@platformapro.com
"""

}

#Preview {
    AlertPrivacyPolice(show: .constant(true), infoTextAlert: "")
}
