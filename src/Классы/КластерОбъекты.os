Перем Владелец;
Перем Элементы;

Перем МоментАктуальности;
Перем ПериодОбновления;

Процедура ПриСозданииОбъекта(ВладелецЭлементов)

	Элементы = Неопределено;

	Владелец = ВладелецЭлементов;

	ПериодОбновления = 60000;
	МоментАктуальности = 0;

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура заполняет список элементов из переданного массива
//   
// Параметры:
//   МассивЭлементов 	- Массив		- элементы, которые будут добавлены
//
Процедура Заполнить(МассивЭлементов) Экспорт

	Элементы = МассивЭлементов;

КонецПроцедуры // Заполнить()

// Процедура добавляет элемент в список
//   
// Параметры:
//   Элемент 	- Произвольный		- добавляемый элемент
//
Процедура Добавить(Элемент) Экспорт

	Элементы.Добавить(Элемент);

КонецПроцедуры // Добавить()

// Функция признак необходимости обновления данных
//   
// Параметры:
//   ОбновитьПринудительно 	- Булево		- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Булево - Истина - требуется обновитьданные
//
Функция ТребуетсяОбновление(ОбновитьПринудительно = Ложь) Экспорт

	Возврат (ОбновитьПринудительно
		ИЛИ Элементы = Неопределено
		ИЛИ НЕ (ПериодОбновления < (МоментАктуальности - ТекущаяУниверсальнаяДатаВМиллисекундах())));

КонецФункции // ТребуетсяОбновление()

// Функция возвращает список объектов кластера
//   
// Параметры:
//   ПоляУпорядочивания 	- Строка		- Список полей упорядочивания списка администратор, разделенные ","
//											  если не указаны, то имя администратора name
//   ОбновитьПринудительно 		- Булево	- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - список администраторов агента кластеров 1С
//
Функция ПолучитьСписок(Знач ПоляУпорядочивания = "", ОбновитьПринудительно = Ложь) Экспорт

	Владелец.ОбновитьДанные(ОбновитьПринудительно);

	Возврат Служебный.ИерархическоеПредставлениеМассиваСоответствий(Элементы, ПоляУпорядочивания);

КонецФункции // ПолучитьСписок()

// Функция возвращает описание объекта кластера
//   
// Параметры:
//   Отбор				 	- Структура	- Структура отбора сеансов (<поле>:<значение>)
//   ОбновитьПринудительно 	- Булево	- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - описание администратора агента кластеров 1С
//
Функция Получить(Отбор, ОбновитьПринудительно = Ложь) Экспорт

	Владелец.ОбновитьДанные(ОбновитьПринудительно);

	Результат = Служебный.ПолучитьЭлементыИзМассиваСоответствий(Элементы, Отбор);

	Если Результат.Количество() = 0 Тогда
		Возврат Неопределено;
	ИначеЕсли Результат.Количество() = 1 Тогда
		Возврат Результат[0];
	Иначе
		Возврат Результат;
	КонецЕсли;

КонецФункции // Получить()

// Процедура устанавливает значение периода обновления
//   
// Параметры:
//   НовыйПериодОбновления 	- Число		- новый период обновления
//
Процедура УстановитьПериодОбновления(НовыйПериодОбновления) Экспорт

	ПериодОбновления = НовыйПериодОбновления;

КонецПроцедуры // УстановитьПериодОбновления()

// Процедура устанавливает новое значение момента актуальности данных
//   
Процедура УстановитьАктуальность() Экспорт

	МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();

КонецПроцедуры // УстановитьАктуальность()
