#Использовать fs
#Использовать 1commands
#Использовать tempfiles
#Использовать json

Перем Лог;
///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, "     Проверка проекта EDT.");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--junitpath", "Путь отчета в формате JUnit");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--allure-results", "Путь к каталогу сохранения результатов тестирования в формате Allure (xml)");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--allure-results2", "Путь к каталогу сохранения результатов тестирования в формате Allure2 (json)");
	Парсер.ДобавитьПараметрФлагКоманды(ОписаниеКоманды, "--clear-reports", "Очищать каталоги отчетов перед проверкой");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--exception-file",
	"Путь файла с указанием пропускаемых ошибок. Необязательный аргумент.
	|	Формат файла: в каждой строке файла указан текст пропускаемого исключения или его часть
	|	Кодировка: UTF-8");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--validation-result",
	"Путь к файлу, в который будут записаны результаты проверки проекта. Необязательный аргумент, если .");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--prev-validation-result",
	"Путь к файлу с предыдущими результатами проверки проекта. Необязательный аргумент.
	|	Если заполнен, то результат будет записан как разность новых ошибок и старых.
	|	Ошибки и предупреждения, которые есть в предыдущем файле, но которых нет в новом - будут помечены как passed (Исправлено).
	|	Ошибки и предупреждения, которые есть только в новом файле результатов - будут помечены как failed (Ошибки) и broken (Предупреждения).
	|	Все остальные ошибки и предупреждения, которые есть в обоих файлах, будут помечены как skipped (Пропущено).");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--project-url",
	"Путь к файлам проекта. Необязательный аргумент.
	|	Если заполнен, то в отчетах аллюр будут ссылки на конкретные строки с ошибками.
	|	Пример: --project-url https://github.com/1C-Company/GitConverter/tree/master/GitConverter/src ");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--EDTversion",
	"Используемая версия EDT. Необязательный аргумент.
	|	Необходима, если зарегистрировано одновременно несколько версий.
	|	Узнать доступные версии можно командой ""ring help""
	|	Пример: --EDTversion 1.9.1");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--workspace-location",
	"Расположение рабочей области. Необязательный аргумент.
	|	Если не указан, то проверка выполняться не будет. Актуально для создания отчетов по существующему файлу результатов.");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--project-list",
	"Список папок, откуда загрузить проекты в формате EDT для проверки. Необязательный аргумент.
	|	Одновременно можно использовать только один аргумент: project-list или project-name-list");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--project-name-list",
	"Список имен проектов в текущей рабочей области, откуда загрузить проекты в формате EDT для проверки. Необязательный аргумент.
	|	Одновременно можно использовать только один аргумент: project-list или project-name-list.
	|
	|	Примеры выполнения:
	|		vanessa-runner edt-validate --project-list D:/project-1 D:/project-2 --workspace-location D:/workspace
	|		runner edt-validate --allure-results ""D:/allure-results/"" ^
	|			--workspace-location ""D:/workspace"" ^
	|			--project-list ""D:/GIT_Repo/GitConverter/"" ^
	|			--exception-file ""D:/WORKDIR%excp.txt"" ^
	|			--validation-result ""D:/validation-result.txt"" ^
	|			--prev-validation-result ""D:/validation-result.txt"" ^
	|			--project-url https://github.com/1C-Company/GitConverter/tree/master/GitConverter/src
	|
	|	ВНИМАНИЕ! Параметры, которые перечислены далее, не используются.
	|
	|");

	Парсер.ДобавитьКоманду(ОписаниеКоманды);

КонецПроцедуры

// Выполняет логику команды
//
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   ДополнительныеПараметры - Соответствие -  (необязательно) дополнительные параметры
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач ДополнительныеПараметры = Неопределено) Экспорт

	Лог = ДополнительныеПараметры.Лог;
	ОчищатьКаталогОтчетов = ПараметрыКоманды["--clear-reports"];

	ПутьОтчетаВФорматеJUnitxml = ПараметрыКоманды["--junitpath"];
	Если ПутьОтчетаВФорматеJUnitxml = Неопределено Тогда
		ПутьОтчетаВФорматеJUnitxml = "";
	КонецЕсли;

	ПутьОтчетаВФорматеAllure = ПараметрыКоманды["--allure-results"];
	Если ПутьОтчетаВФорматеAllure = Неопределено Тогда
		ПутьОтчетаВФорматеAllure = "";
	ИначеЕсли ОчищатьКаталогОтчетов Тогда
		ФС.ОбеспечитьПустойКаталог(ПутьОтчетаВФорматеAllure);
	КонецЕсли;

	ПутьОтчетаВФорматеAllure2 = ПараметрыКоманды["--allure-results2"];
	Если ПутьОтчетаВФорматеAllure2 = Неопределено Тогда
		ПутьОтчетаВФорматеAllure2 = "";
	ИначеЕсли ОчищатьКаталогОтчетов Тогда
		ФС.ОбеспечитьПустойКаталог(ПутьОтчетаВФорматеAllure2);
	КонецЕсли;

	СохранятьОтчетВФайл = ЗначениеЗаполнено(ПутьОтчетаВФорматеJUnitxml)
							ИЛИ ЗначениеЗаполнено(ПутьОтчетаВФорматеAllure)
							ИЛИ ЗначениеЗаполнено(ПутьОтчетаВФорматеAllure2);

	ВерсияEDT = ПараметрыКоманды["--EDTversion"];
	РабочаяОбласть = ПараметрыКоманды["--workspace-location"];
	СписокПапокСПроектами = ПараметрыКоманды["--project-list"];
	СписокИменПроектов = ПараметрыКоманды["--project-name-list"];
	ПутьКФайламПроекта = ПараметрыКоманды["--project-url"];

	ИмяФайлаРезультата = ПараметрыКоманды["--validation-result"];
	УдалятьФайлРезультата = Ложь;

	Если ИмяФайлаРезультата = Неопределено Тогда

		ИмяФайлаРезультата = ВременныеФайлы.НовоеИмяФайла("out");
		УдалятьФайлРезультата = Истина;

	КонецЕсли;

	ИмяФайлаИсключенийОшибок = ПараметрыКоманды["--exception-file"];

	ИмяПредыдущегоФайлаРезультата = ПараметрыКоманды["--prev-validation-result"];

	ДатаНачала = ТекущаяДата();
	Успешно = ВыполнитьПроверкуEDT(РабочаяОбласть, ИмяФайлаРезультата, СписокПапокСПроектами, СписокИменПроектов, ВерсияEDT);

	Если СохранятьОтчетВФайл Тогда

		РезультатТестирования = ОбработатьЛогОшибок(ДатаНачала, ИмяФайлаРезультата, ИмяФайлаИсключенийОшибок, ИмяПредыдущегоФайлаРезультата);
		Если ЗначениеЗаполнено(ПутьОтчетаВФорматеAllure) Тогда

			Лог.Информация("Генерация отчета Allure");
			ГенерацияОтчетов.СформироватьОтчетВФорматеAllure(РезультатТестирования.ДатаНачала, РезультатТестирования, ПутьОтчетаВФорматеAllure, "EDT");

		КонецЕсли;

		Если ЗначениеЗаполнено(ПутьОтчетаВФорматеAllure2) Тогда

			Лог.Информация("Генерация отчета Allure2");
			ГенерацияОтчетов.СформироватьОтчетВФорматеAllure2(РезультатТестирования.ДатаНачала, РезультатТестирования, ПутьОтчетаВФорматеAllure2, "EDT", ПутьКФайламПроекта);

		КонецЕсли;

		Если ЗначениеЗаполнено(ПутьОтчетаВФорматеJUnitxml) Тогда

			Лог.Информация("Генерация отчета JUnit");
			ГенерацияОтчетов.СформироватьОтчетВФорматеJUnit(РезультатТестирования, ПутьОтчетаВФорматеJUnitxml, "edt");

		КонецЕсли;

	КонецЕсли;

	Если УдалятьФайлРезультата Тогда

		ОбщиеМетоды.УдалитьФайлЕслиОнСуществует(ИмяФайлаРезультата);

	КонецЕсли;

	РезультатыКоманд = МенеджерКомандПриложения.РезультатыКоманд();
	Возврат ?(Успешно, РезультатыКоманд.Успех, РезультатыКоманд.ОшибкаВремениВыполнения);

КонецФункции

///////////////////////////////////////////////////////////////////////////////////////////////////

Функция ВыполнитьПроверкуEDT(Знач РабочаяОбласть, ИмяФайлаРезультата, СписокПапокСПроектами, СписокИменПроектов, ВерсияEDT)

	Если Не ЗначениеЗаполнено(РабочаяОбласть) Тогда

		Лог.Информация("Рабочая область (--workspace-location) не указана. Проверка проекта пропущена.");
		Возврат Истина;

	КонецЕсли;

	ФайлРабочаяОбласть = Новый Файл(РабочаяОбласть);
	РабочаяОбласть = ФайлРабочаяОбласть.ПолноеИмя;

	Если Не ЗначениеЗаполнено(СписокПапокСПроектами)
		И Не ЗначениеЗаполнено(СписокИменПроектов) Тогда

		Лог.Информация("Проекты к проверке (--project-list или project-name-list) не указаны. Проверка проекта пропущена.");

		Возврат Истина;

	КонецЕсли;

	Попытка

		// Для EDT критично, чтобы файла не существовало
		ОбщиеМетоды.УдалитьФайлЕслиОнСуществует(ИмяФайлаРезультата);

		Команда = Новый Команда;
		Команда.УстановитьСтрокуЗапуска(СтрШаблон("ring edt%1 workspace validate", ?(ПустаяСтрока(ВерсияEDT), "", "@" + ВерсияEDT)));
		Команда.УстановитьКодировкуВывода(КодировкаТекста.ANSI);
		Команда.ДобавитьПараметр("--workspace-location " + ОбщиеМетоды.ОбернутьПутьВКавычки(РабочаяОбласть));
		Команда.ДобавитьПараметр("--file " + ОбщиеМетоды.ОбернутьПутьВКавычки(ИмяФайлаРезультата));

		Если ЗначениеЗаполнено(СписокПапокСПроектами) Тогда
			Команда.ДобавитьПараметр("--project-list " + СписокПапокСПроектами);
		КонецЕсли;

		Если ЗначениеЗаполнено(СписокИменПроектов) Тогда
			Команда.ДобавитьПараметр("--project-name-list " + ОбщиеМетоды.ОбернутьПутьВКавычки(СписокИменПроектов));
		КонецЕсли;

		Лог.Информация("Начало проверки EDT-проекта");
		НачалоЗамера = ТекущаяДата();

		КодВозврата = Команда.Исполнить();

		Лог.Информация("Проверка EDT-проекта завершена за %1с", Окр(ТекущаяДата() -  НачалоЗамера));

	Исключение

		ВызватьИсключение ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());

	КонецПопытки;

	Результат = (КодВозврата = 0);
	Если Не Результат Тогда
		Лог.Ошибка("Возникла ошибка: код возврата %1,
		|%2", КодВозврата, Команда.ПолучитьВывод());
	КонецЕсли;

	Возврат Результат;

КонецФункции

Функция ОбработатьЛогОшибок(ДатаНачала, ПутьКФайлуЛогаОшибок, ИмяФайлаИсключенийОшибок, ИмяПредыдущегоФайлаРезультата)

	РезультатТестирования = Новый Структура;
	РезультатТестирования.Вставить("Ошибки", Новый Соответствие);
	РезультатТестирования.Вставить("ВсеОшибки", "");
	РезультатТестирования.Вставить("ДатаНачала", ДатаНачала);
	РезультатТестирования.Вставить("КоличествоПроверок", 0);
	РезультатТестирования.Вставить("КоличествоПропущено", 0);
	РезультатТестирования.Вставить("КоличествоУпало", 0);

	Файл = Новый Файл(ПутьКФайлуЛогаОшибок);
	Если Не Файл.Существует() Тогда

		// Файла может не быть если
		// 1) Нет ошибок (EDT просто не создает файл результата)
		// 2) EDT вернул ошибку
		// 3) Проверка EDT не запускалась, выполняется только построение отчета Аллюр

		Возврат РезультатТестирования;

	КонецЕсли;

	ФайлЛога = Новый ТекстовыйДокумент();
	ФайлЛога.Прочитать(ПутьКФайлуЛогаОшибок, КодировкаТекста.UTF8);

	ЛогПроверкиИзКонфигуратора = ФайлЛога.ПолучитьТекст();

	// Определяем строки для исключения из ошибок
	// См. стандарт "Обработчики событий модуля формы, подключаемые из кода"
	// https://its.1c.ru/db/v8std#content:-2145783155:hdoc
	МассивСтрокИсключений = Новый Массив();
	МассивСтрокИсключений.Добавить(Нрег("Неиспользуемый метод ""Подключаемый_"));
	МассивСтрокИсключений.Добавить(Нрег("Пустой обработчик: ""Подключаемый_"));
	МассивСтрокИсключений.Добавить(Нрег("Empty handler: ""Attachable_"));

	ПропускаемыеОшибки = СодержимоеФайлаИсключенийОшибок(ИмяФайлаИсключенийОшибок);
	СтарыеОшибки = СодержимоеПрошлогоОтчетаОбОшибках(ИмяПредыдущегоФайлаРезультата);

	Для Каждого ТекСтрока Из СтрРазделить(ЛогПроверкиИзКонфигуратора, Символы.ПС) Цикл

		СтарыеОшибки.Удалить(ТекСтрока); // оставим только разницу
		Если ИсключитьСтроку(ТекСтрока, МассивСтрокИсключений) Тогда
			Продолжить;
		КонецЕсли;

		РезультатТестирования.ВсеОшибки = РезультатТестирования.ВсеОшибки + ТекСтрока + Символы.ПС;

		ОписаниеОшибки = ПолучитьОписаниеОшибки(ТекСтрока);
		ДополнитьРезультатТекстомОшибки(РезультатТестирования, ОписаниеОшибки, ПропускаемыеОшибки, ТекСтрока);

	КонецЦикла;

	// старые ошибки пометим как исправленные
	Для Каждого ТекСтрока Из СтарыеОшибки Цикл

		Если ИсключитьСтроку(ТекСтрока.Ключ, МассивСтрокИсключений) Тогда
			Продолжить;
		КонецЕсли;

		ОписаниеОшибки = ПолучитьОписаниеОшибки(ТекСтрока.Ключ, "Исправлено");
		ДополнитьРезультатТекстомОшибки(РезультатТестирования, ОписаниеОшибки);

	КонецЦикла;

	Возврат РезультатТестирования;

КонецФункции

Функция ИсключитьСтроку(Знач ПроверяемаяСтрока, Знач МассивСтрокИсключений)

	Если ПустаяСтрока(ПроверяемаяСтрока) Тогда

		Возврат Истина;

	КонецЕсли;

	Для Каждого СтрИсключения Из МассивСтрокИсключений Цикл

		Если СтрНайти(Нрег(ПроверяемаяСтрока), СтрИсключения) > 0 Тогда

			Возврат Истина;

		КонецЕсли;

	КонецЦикла;

	Возврат Ложь;

КонецФункции

Функция ПолучитьОписаниеОшибки(Знач СтрокаЛога, Знач ТипОшибки = "")

	АнализируемаяСтрока = СокрЛП(СтрокаЛога);
	ЭлементыСтроки = СтрРазделить(АнализируемаяСтрока, Символы.Таб);
	Если Не ЗначениеЗаполнено(ТипОшибки) Тогда
		ТипОшибки = ЭлементыСтроки.Получить(1);
	КонецЕсли;

	ИмяГруппы = ЭлементыСтроки.Получить(3);
	НомерСтроки = СокрЛП(СтрЗаменить(ЭлементыСтроки.Получить(4), "строка", ""));
	Для Ит = 0 По 4 Цикл

		ЭлементыСтроки.Удалить(0);

	КонецЦикла;

	ТекстОшибки = СокрЛП(СтрСоединить(ЭлементыСтроки, Символы.Таб));
	Возврат ШаблонОписанияОшибки(ИмяГруппы, ТекстОшибки, НомерСтроки, ТипОшибки);

КонецФункции

Функция ШаблонОписанияОшибки(ИмяПоУмолчанию = "", ТекстОшибки = "", НомерСтроки = 0, ТипОшибки = "Ошибка")

	Возврат Новый Структура("ТекстОшибки, ИмяГруппы, НомерСтроки, ТипОшибки", ТекстОшибки, ИмяПоУмолчанию, НомерСтроки, ТипОшибки);

КонецФункции

Процедура ДополнитьРезультатТекстомОшибки(Результат, ОписаниеОшибки, Знач ПропускаемыеОшибки = Неопределено, СтрокаЛога = "")

	Если СледуетПропуститьОшибку(СтрокаЛога, ПропускаемыеОшибки) Тогда

		ОписаниеОшибки.ТипОшибки = "Пропущено";

	КонецЕсли;

	ОшибкиГруппы = Результат.Ошибки.Получить(ОписаниеОшибки.ИмяГруппы);

	Если ОшибкиГруппы = Неопределено Тогда

		ОшибкиГруппы = Новый Соответствие();

	КонецЕсли;

	ОшибкиПоТипу = ОшибкиГруппы.Получить(ОписаниеОшибки.ТипОшибки);
	Если ОшибкиПоТипу = Неопределено Тогда

		Результат.КоличествоПроверок = Результат.КоличествоПроверок + 1;
		Если ОписаниеОшибки.ТипОшибки = "Ошибка" Тогда
			Результат.КоличествоУпало = Результат.КоличествоУпало + 1;
		Иначе
			Результат.КоличествоПропущено = Результат.КоличествоПропущено + 1;
		КонецЕсли;

		ОшибкиПоТипу = Новый Массив();

	КонецЕсли;

	ОшибкиПоТипу.Добавить(ОписаниеОшибки);
	ОшибкиГруппы.Вставить(ОписаниеОшибки.ТипОшибки, ОшибкиПоТипу);
	Результат.Ошибки.Вставить(ОписаниеОшибки.ИмяГруппы, ОшибкиГруппы);

КонецПроцедуры

Функция СледуетПропуститьОшибку(Знач СтрокаСОшибкой, Знач ПропускаемыеОшибки)

	Если НЕ ЗначениеЗаполнено(ПропускаемыеОшибки) ИЛИ НЕ ЗначениеЗаполнено(СтрокаСОшибкой) Тогда

		Возврат Ложь;

	КонецЕсли;

	Для Каждого ТекИсключение Из ПропускаемыеОшибки Цикл
		Если СтрНайти(НормализованныйТекстОшибки(СтрокаСОшибкой), ТекИсключение) > 0 Тогда

			Возврат Истина;

		КонецЕсли;
	КонецЦикла;

	Возврат Ложь;

КонецФункции

Функция НормализованныйТекстОшибки(Знач ТекстОшибки)

	Возврат СокрЛП(НРег(ТекстОшибки));

КонецФункции

Функция СодержимоеФайлаИсключенийОшибок(Знач ИмяФайлаПропускаемыхОшибок)

	Результат = Новый Массив;

	Если Не ЗначениеЗаполнено(ИмяФайлаПропускаемыхОшибок) Тогда
		Возврат Результат;
	КонецЕсли;

	Файл = Новый Файл(ИмяФайлаПропускаемыхОшибок);
	Если Не Файл.Существует() Тогда
		Возврат Результат;
	КонецЕсли;

	ЧтениеТекста = Новый ЧтениеТекста(ИмяФайлаПропускаемыхОшибок, КодировкаТекста.UTF8);
	ПрочитаннаяСтрока = ЧтениеТекста.ПрочитатьСтроку();
	Пока ПрочитаннаяСтрока <> Неопределено Цикл
		Если Не ПустаяСтрока(ПрочитаннаяСтрока) Тогда
			Результат.Добавить(НормализованныйТекстОшибки(ПрочитаннаяСтрока));
		КонецЕсли;
		ПрочитаннаяСтрока = ЧтениеТекста.ПрочитатьСтроку();
	КонецЦикла;

	ЧтениеТекста.Закрыть();
	Возврат Результат;

КонецФункции

Функция СодержимоеПрошлогоОтчетаОбОшибках(Знач ИмяФайла)

	Результат = Новый Соответствие();

	Если Не ЗначениеЗаполнено(ИмяФайла) Тогда
		Возврат Результат;
	КонецЕсли;

	Файл = Новый Файл(ИмяФайла);
	Если Не Файл.Существует() Тогда
		Возврат Результат;
	КонецЕсли;

	ЧтениеТекста = Новый ЧтениеТекста(ИмяФайла, КодировкаТекста.UTF8);
	ПрочитаннаяСтрока = ЧтениеТекста.ПрочитатьСтроку();
	Пока ПрочитаннаяСтрока <> Неопределено Цикл
		Результат.Вставить(ПрочитаннаяСтрока, "1");
		ПрочитаннаяСтрока = ЧтениеТекста.ПрочитатьСтроку();
	КонецЦикла;

	ЧтениеТекста.Закрыть();
	Возврат Результат;

КонецФункции
