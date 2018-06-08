Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем Сервер_Владелец;
Перем ПараметрыОбъекта;
Перем Элементы;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера		- АгентКластера	- ссылка на родительский объект агента кластера
//   Кластер			- Кластер		- ссылка на родительский объект кластера
//   Сервер				- Сервер		- ссылка на родительский объект сервера кластера
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, Сервер)

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;
	Сервер_Владелец = Сервер;

	ПараметрыОбъекта = Новый ПараметрыОбъекта("rule");

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

	ПараметрыЗапуска.Добавить("rule");
	ПараметрыЗапуска.Добавить("list");

	ПараметрыЗапуска.Добавить(СтрШаблон("--server=%1", Сервер_Владелец.Ид()));

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());

	Кластер_Агент.ВыполнитьКоманду(ПараметрыЗапуска);
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	МассивНазначений = Новый Массив();
	Для Каждого ТекОписание Из МассивРезультатов Цикл
		МассивНазначений.Добавить(Новый НазначениеФункциональности(Кластер_Агент,
																	Кластер_Владелец,
																	Сервер_Владелец,
																	ТекОписание));
	КонецЦикла;

	Элементы.Заполнить(МассивНазначений);

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

// Функция возвращает список требований назначения функциональности сервера 1С
//   
// Параметры:
//   Отбор					 	- Структура	- Структура отбора требований
//											  назначения функциональности (<поле>:<значение>)
//   ОбновитьПринудительно 		- Булево	- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Массив - список требований назначения функциональности сервера 1С
//
Функция Список(Отбор = Неопределено, ОбновитьПринудительно = Ложь) Экспорт

	СписокНазначений = Элементы.Список(Отбор, ОбновитьПринудительно);
	
	Возврат СписокНазначений;

КонецФункции // Список()

// Функция возвращает список требований назначения функциональности сервера 1С
//   
// Параметры:
//   ПоляИерархии 			- Строка		- Поля для построения иерархии списка требований
//											  назначения функциональности, разделенные ","
//   ОбновитьПринудительно 	- Булево		- Истина - обновить список (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - список требований назначения функциональности сервера 1С
//		<имя поля объекта>	- Массив(Соответствие), Соответствие	- список требований назначения функциональности
//																	  или следующий уровень
//
Функция ИерархическийСписок(Знач ПоляИерархии, ОбновитьПринудительно = Ложь) Экспорт

	СписокКластеров = Элементы.ИерархическийСписок(ПоляИерархии, ОбновитьПринудительно);
	
	Возврат СписокКластеров;

КонецФункции // ИерархическийСписок()

// Функция возвращает количество требований назначения функциональности в списке
//   
// Возвращаемое значение:
//	Число - количество требований назначения функциональности
//
Функция Количество() Экспорт

	Если Элементы = Неопределено Тогда
		Возврат 0;
	КонецЕсли;
	
	Возврат Элементы.Количество();

КонецФункции // Количество()

// Функция возвращает описание требования назначения функциональности сервера 1С
//   
// Параметры:
//   Ид	 					- Строка	- Идентификатор требований назначения функциональности
//   ОбновитьПринудительно 	- Булево	- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - описание требования назначения функциональности сервера 1С
//
Функция Получить(Знач Ид, Знач ОбновитьПринудительно = Ложь) Экспорт

	Отбор = Новый Соответствие();
	Отбор.Вставить("rule", Ид);

	СписокТребований = Элементы.Список(Отбор, ОбновитьПринудительно);
	
	Если СписокТребований.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат СписокТребований[0];

КонецФункции // Получить()

// Процедура добавляет новое требование назначения функциональности для сервера 1С
//   
// Параметры:
//   Позиция			 	- Число			- позиция требования назначения функциональности в списке (начиная с 0)
//   ПараметрыТребования 	- Структура		- параметры сервера 1С
//
Процедура Добавить(Позиция, ПараметрыТребования = Неопределено) Экспорт

	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("rule");
	ПараметрыЗапуска.Добавить("insert");

	ПараметрыЗапуска.Добавить(СтрШаблон("--server=%1", Сервер_Владелец.Ид()));

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());

	ПараметрыЗапуска.Добавить(СтрШаблон("--position=%1", Позиция));

	ВремПараметры = ПараметрыОбъекта();

	Для Каждого ТекЭлемент Из ВремПараметры Цикл
		ЗначениеПараметра = Служебный.ПолучитьЗначениеИзСтруктуры(ПараметрыТребования, ТекЭлемент.Ключ, 0);
		ПараметрыЗапуска.Добавить(СтрШаблон(ТекЭлемент.Значение.ПараметрКоманды + "=%1", ЗначениеПараметра));
	КонецЦикла;

	Кластер_Агент.ВыполнитьКоманду(ПараметрыЗапуска);
	
	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные();

КонецПроцедуры // Добавить()

// Процедура удаляет требование назначения функциональности для сервера 1С
//   
// Параметры:
//   Ид			- Строка	- Идентификатор требования назначения функциональности 
//
Процедура Удалить(Ид) Экспорт
	
	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("rule");
	ПараметрыЗапуска.Добавить("remove");

	ПараметрыЗапуска.Добавить(СтрШаблон("--rule=%1", Ид));

	ПараметрыЗапуска.Добавить(СтрШаблон("--server=%1", Сервер_Владелец.Ид()));

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());
	
	Кластер_Агент.ВыполнитьКоманду(ПараметрыЗапуска);
	
	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные();

КонецПроцедуры // Удалить()

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
