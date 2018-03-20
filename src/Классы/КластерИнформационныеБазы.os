Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем Элементы;
Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера		- АгентКластера	- ссылка на родительский объект агента кластера
//   Кластер			- Кластер		- ссылка на родительский объект кластера
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер)

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;

	ОбновитьДанные();

КонецПроцедуры

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
Процедура ОбновитьДанные()
	
	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("infobase");
	ПараметрыЗапуска.Добавить("summary");
	ПараметрыЗапуска.Добавить("list");

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());

	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	МассивРезультатов = Служебный.РазобратьВыводКоманды(Служебный.ВыводКоманды());

	Элементы = Новый Соответствие();
	Для Каждого ТекОписание Из МассивРезультатов Цикл
		Элементы.Вставить(ТекОписание["name"], Новый ИнформационнаяБаза(Кластер_Агент, Кластер_Владелец, ТекОписание["infobase"]));
	КонецЦикла;

КонецПроцедуры // ОбновитьДанные()

// Функция возвращает список информационных баз 1С
//   
// Параметры:
//   ОбновитьДанные 	- Булево		- Истина - обновить список (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - список информационных баз 1С
//
Функция ПолучитьСписок(ОбновитьДанные = Ложь) Экспорт

	Если ОбновитьДанные Тогда
		ОбновитьДанные();
	КонецЕсли;

	Возврат Элементы;

КонецФункции // ПолучитьСписок()

// Функция возвращает описание информационной базы 1С
//   
// Параметры:
//   Имя			 	- Строка		- Имя информационной базы 1С
//   ОбновитьДанные 	- Булево		- Истина - обновить список (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - описание информационной базы 1С
//
Функция Получить(Имя, ОбновитьДанные = Ложь) Экспорт

	Если ОбновитьДанные Тогда
		ОбновитьДанные();
	КонецЕсли;

	Возврат Элементы[Имя];

КонецФункции // Получить()

// Процедура добавляет новую информационную базу
//   
// Параметры:
//   Имя			 	- Строка		- имя информационной базы
//   Локализация	 	- Строка		- локализация базы
//   СоздатьБазуСУБД 	- Булево		- Истина - создать базу данных на сервере СУБД; Ложь - не создавать
//   ПараметрыИБ	 	- Структура		- параметры информационной базы
//
Процедура Добавить(Имя, Локализация = "ru_RU", СоздатьБазуСУБД = Ложь, ПараметрыИБ = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыИБ) = Тип("Структура") Тогда
		ПараметрыИБ = Новый Структура();
	КонецЕсли;

	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("infobase");
	ПараметрыЗапуска.Добавить("create");

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());

	ПараметрыЗапуска.Добавить(СтрШаблон("--name=%1", Имя));
	ПараметрыЗапуска.Добавить(СтрШаблон("--locale=%1", Локализация));
	
	Если СоздатьБазуСУБД Тогда
		ПараметрыЗапуска.Добавить(СтрШаблон("--create-database", Имя));
	КонецЕсли;

	ВремИБ = Новый ИнформационнаяБаза(Кластер_Агент, Кластер_Владелец);

	ПараметрыОбъекта = ВремИБ.ПолучитьСтруктуруПараметровОбъекта();

	Для Каждого ТекЭлемент Из ПараметрыОбъекта Цикл
		ЗначениеПараметра = Служебный.ПолучитьЗначениеИзСтруктуры(ПараметрыИБ, ТекЭлемент.Ключ, 0)
		ПараметрыЗапуска.Добавить(СтрШаблон(ТекЭлемент.Значение.ПараметрКоманды + "=%1", ЗначениеПараметра));
	КонецЦикла;

	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	Лог.Информация(Служебный.ВыводКоманды());

	ОбновитьДанные();

КонецПроцедуры // Добавить()

// Процедура удаляет информационную базу
//   
// Параметры:
//   Имя			 	- Строка		- имя информационной базы
//   ДействияСБазойСУБД	- Строка		- "drop" - удалить базу данных; "clear" - очистить базу данных;
//										  иначе оставить базу данных как есть
//
Процедура Удалить(Имя, ДействияСБазойСУБД = "") Экспорт
	
	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("infobase");
	ПараметрыЗапуска.Добавить("drop");

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());
	
	ПараметрыЗапуска.Добавить(СтрШаблон("--infobase=%1", Получить(Имя).Ид()));
	ПараметрыЗапуска.Добавить(Получить(Имя).СтрокаАвторизации());

	Если ДействияСБазойСУБД = "drop" Тогда
		ПараметрыЗапуска.Добавить("--drop-database");
	ИначеЕсли ДействияСБазойСУБД = "clear" Тогда
		ПараметрыЗапуска.Добавить("--clear-database");
	КонецЕсли;

	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	Лог.Информация(Служебный.ВыводКоманды());

	ОбновитьДанные();

КонецПроцедуры //Удалить()

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
