Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем Процесс_Владелец;
Перем ИБ_Владелец;

Перем ПараметрыОбъекта;
Перем Элементы;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера	- АгентКластера			- ссылка на родительский объект агента кластера
//   Кластер		- Кластер				- ссылка на родительский объект кластера
//   Процесс		- РабочийПроцесс		- ссылка на родительский объект рабочего процесса
//   ИБ				- ИнформационнаяБаза	- ссылка на родительский объект информационной базы
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, Процесс = Неопределено, ИБ = Неопределено)

	Кластер_Агент		= АгентКластера;
	Кластер_Владелец	= Кластер;
	Процесс_Владелец	= Процесс;
	ИБ_Владелец			= ИБ;

	ПараметрыОбъекта = Новый ПараметрыОбъекта("connection");

	Элементы = Новый ОбъектыКластера(ЭтотОбъект);

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно 		- Булево	- Истина - принудительно обновить данные (вызов RAC)
//											- Ложь - данные будут получены если истекло время актуальности
//													или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь) Экспорт
	
	Если НЕ Элементы.ТребуетсяОбновление(ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("connection");
	ПараметрыЗапуска.Добавить("list");

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());

	Если НЕ Процесс_Владелец = Неопределено Тогда
		ПараметрыЗапуска.Добавить(СтрШаблон("--process=%1", Процесс_Владелец.Получить("process")));
	КонецЕсли;

	Если НЕ ИБ_Владелец = Неопределено Тогда
		ПараметрыЗапуска.Добавить(СтрШаблон("--infobase=%1", ИБ_Владелец.Ид()));
		ПараметрыЗапуска.Добавить(СтрШаблон(ИБ_Владелец.СтрокаАвторизации()));
	КонецЕсли;

	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	Элементы.Заполнить(Служебный.РазобратьВыводКоманды(Служебный.ВыводКоманды()));

	Элементы.УстановитьАктуальность();

КонецПроцедуры // ОбновитьДанные()

// Функция возвращает коллекцию параметров объекта
//   
// Параметры:
//   ИмяПоляКлюча 		- Строка	- имя поля, значение которого будет использовано
//									  в качестве ключа возвращаемого соответствия
//   
// Возвращаемое значение:
//	Соответствие - коллекция параметров объекта, для получения/изменения значений
//
Функция ПараметрыОбъекта(ИмяПоляКлюча = "ИмяПараметра") Экспорт

	Возврат ПараметрыОбъекта.Получить(ИмяПоляКлюча);

КонецФункции // ПараметрыОбъекта()

// Функция возвращает список соединений
//   
// Параметры:
//   Отбор					 	- Структура	- Структура отбора соединений (<поле>:<значение>)
//   ОбновитьПринудительно 		- Булево	- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Массив - список соединений
//
Функция Список(Отбор = Неопределено, ОбновитьПринудительно = Ложь) Экспорт

	Сеансы = Элементы.Список(Отбор, ОбновитьПринудительно);
	
	Возврат Сеансы;

КонецФункции // Список()

// Функция возвращает список соединений
//   
// Параметры:
//   ПоляИерархии			- Строка		- Поля для построения иерархии списка соединений, разделенные ","
//   ОбновитьПринудительно	- Булево		- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - список соединений
//
Функция ИерархическийСписок(Знач ПоляИерархии, ОбновитьПринудительно = Ложь) Экспорт

	Сеансы = Элементы.ИерархическийСписок(ПоляИерархии, ОбновитьПринудительно);

	Возврат Сеансы;

КонецФункции // ИерархическийСписок()

// Функция возвращает описание соединения
//   
// Параметры:
//   Номер				 	- Структура	- Номер соединения
//   ОбновитьПринудительно 	- Булево	- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - описание соединения
//
Функция Получить(Знач Номер, Знач ОбновитьПринудительно = Ложь) Экспорт

	Отбор = Новый Соответствие();
	Отбор.Вставить("conn-id", Номер);

	Сеансы = Элементы.Список(Отбор, ОбновитьПринудительно);

	Возврат Сеансы[0];

КонецФункции // Получить()

// Процедура отключает соединение
//   
// Параметры:
//   Номер				 	- Структура	- Номер соединения
//
Процедура Отключить(Знач Номер) Экспорт

	Соединение = Получить(Номер, Истина);

	Если Соединение = Неопределено Тогда
		Возврат;
	КонецЕсли;

	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("connection");
	ПараметрыЗапуска.Добавить("list");

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());

	ПараметрыЗапуска.Добавить(СтрШаблон("--process=%1", Соединение.Получить("process")));

	ОтборИБ = Новый Соответствие();
	ОтборИБ.Вставить("infobase", Соединение.Получить("infobase"));

	СписокИБ = КластерВладелец.ИнформационныеБазы().Список(ОтборИБ);
	Если НЕ СписокИБ.Количество() = 0 Тогда
		ПараметрыЗапуска.Добавить(СтрШаблон(СписокИБ[0].СтрокаАвторизации()));
	КонецЕсли;

	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);

КонецПроцедуры // Отключить()

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
