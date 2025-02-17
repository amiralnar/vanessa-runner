///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Выполнение загрузки cf файла в базу данных
//
// TODO добавить фичи для проверки команды
//
// Служебный модуль с набором методов работы с командами приложения
//
// Структура модуля реализована в соответствии с рекомендациями
// oscript-app-template (C) EvilBeaver
//
///////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

Перем Лог; // Экземпляр логгера

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт

	ТекстОписания =
		"     Загрузка cf-файла в базу.";

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды,
		ТекстОписания);

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--src", "Путь к файлу cf, пример: --src=./1Cv8.cf");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "-s",
		"Краткая команда 'путь к cf --src', пример: -s ./1Cv8.cf
		|       В пути файла можно указать шаблонную переменную $version для подстановки в нее версии конфигурации
		|       Пример: 1Cv8_$version.cf выгрузит файл вида 1Cv8_1.2.3.4.cf");
	ОбщиеМетоды.ДобавитьБлокIbcmd(Парсер, ОписаниеКоманды);

	Парсер.ДобавитьКоманду(ОписаниеКоманды);

КонецПроцедуры // ЗарегистрироватьКоманду

// Выполняет логику команды
//
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   ДополнительныеПараметры - Структура - дополнительные параметры (необязательно)
//
//  Возвращаемое значение:
//   Число - Код возврата команды.
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач ДополнительныеПараметры = Неопределено) Экспорт

	Лог = ОбщиеМетоды.ЛогКоманды(ДополнительныеПараметры);

	ДанныеПодключения = ПараметрыКоманды["ДанныеПодключения"];

	ПутьВходящий = ОбщиеМетоды.ПолныйПуть(ОбщиеМетоды.ПолучитьПараметры(ПараметрыКоманды, "-s", "--src"));
	МенеджерВерсий = Новый МенеджерВерсийФайлов1С();
	ПутьВходящийСВерсией = МенеджерВерсий.НайтиФайлСВерсией(ПутьВходящий);

	МенеджерСборки = ОбщиеМетоды.ФабрикаМенеджераСборки(ПараметрыКоманды);
	МенеджерСборки.Конструктор(ДанныеПодключения, ПараметрыКоманды);

	Лог.Информация("Запускаем загрузку конфигурации из cf...");
	Попытка
		МенеджерСборки.ЗагрузитьФайлКонфигурации(ПутьВходящийСВерсией);
	Исключение
		МенеджерСборки.Деструктор();
		ВызватьИсключение;
	КонецПопытки;
	Лог.Информация("Загрузка конфигурации из cf завершена.");

	МенеджерСборки.Деструктор();

	Возврат МенеджерКомандПриложения.РезультатыКоманд().Успех;

КонецФункции

#КонецОбласти
