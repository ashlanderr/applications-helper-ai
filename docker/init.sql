DROP TABLE IF EXISTS applications;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS templates;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE employees (
    id TEXT PRIMARY KEY,
    full_name TEXT NOT NULL,
    department_id INTEGER REFERENCES departments(id),
    job_title TEXT NOT NULL,
    login TEXT
);

CREATE TABLE templates (
    id SERIAL PRIMARY KEY,
    slug TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    tags TEXT[],
    params JSONB NOT NULL
);

CREATE TABLE applications (
    id TEXT PRIMARY KEY,
    created_at TIMESTAMP NOT NULL,
    applicant_id TEXT NOT NULL,
    template_slug TEXT NOT NULL,
    status TEXT NOT NULL,
    params JSONB NOT NULL,
    comment TEXT
);

INSERT INTO departments (id, name) VALUES
(1, 'Разработка'),
(2, 'Тестирование (QA)'),
(3, 'DevOps и инфраструктура'),
(4, 'Аналитика'),
(5, 'IT-служба');

SELECT setval('departments_id_seq', 5);

INSERT INTO employees (id, full_name, department_id, job_title, login) VALUES
('emp_01', 'Иванов Алексей Сергеевич', 1, 'Ведущий разработчик', 'ivanov.as'),
('emp_02', 'Петрова Мария Ивановна', 1, 'Разработчик', 'petrova.mi'),
('emp_03', 'Сидоров Дмитрий Олегович', 1, 'Разработчик', 'sidorov.do'),
('emp_04', 'Козлова Елена Владимировна', 1, 'Техлид', 'kozlova.ev'),
('emp_05', 'Новиков Андрей Петрович', 2, 'QA-инженер', 'novikov.ap'),
('emp_06', 'Морозова Ольга Сергеевна', 2, 'QA-инженер', 'morozova.os'),
('emp_07', 'Волков Игорь Александрович', 2, 'Ведущий QA-инженер', 'volkov.ia'),
('emp_08', 'Соколова Татьяна Михайловна', 2, 'QA-инженер', 'sokolova.tm'),
('emp_09', 'Лебедев Сергей Николаевич', 3, 'DevOps-инженер', 'lebedev.sn'),
('emp_10', 'Кузнецова Анна Дмитриевна', 3, 'DevOps-инженер', 'kuznetsova.ad'),
('emp_11', 'Михайлов Павел Юрьевич', 3, 'Системный администратор', 'mikhailov.py'),
('emp_12', 'Федорова Наталья Алексеевна', 3, 'DevOps-инженер', 'fedorova.na'),
('emp_13', 'Егоров Виктор Иванович', 4, 'Аналитик', 'egorov.vi'),
('emp_14', 'Зайцева Ирина Павловна', 4, 'Ведущий аналитик', 'zaitseva.ip'),
('emp_15', 'Попов Роман Станиславович', 4, 'Аналитик', 'popov.rs'),
('emp_16', 'Васильева Светлана Олеговна', 4, 'Аналитик', 'vasilieva.so'),
('emp_17', 'Семенов Константин Андреевич', 5, 'Менеджер проектов', 'semenov.ka'),
('emp_18', 'Белова Юлия Сергеевна', 5, 'Системный администратор', 'belova.ys'),
('emp_19', 'Громов Артём Вадимович', 5, 'Системный администратор', 'gromov.av'),
('emp_20', 'Орлова Дарья Максимовна', 5, 'Менеджер проектов', 'orlova.dm'),
('emp_21', 'Артёмов Кирилл Сергеевич', 1, 'Разработчик', 'artemov.ks');

INSERT INTO templates (id, slug, title, description, tags, params) VALUES
(1, 'access-request', 'Заявка на доступ к ресурсу', 'Заявка на получение доступа к системе, базе данных или серверу', ARRAY['доступ', 'ресурсы', 'безопасность'],
 '{
    "reason": {"type": "string", "description": "Причина запроса"},
    "resource": {"type": "string", "description": "Название ресурса"},
    "access_level": {"enum": ["чтение", "запись", "админ"], "type": "string", "description": "Уровень доступа"}
  }'),
(2, 'equipment-request', 'Заявка на оборудование', 'Заявка на выдачу или замену компьютерного оборудования', ARRAY['оборудование', 'hardware', 'закупка'],
 '{
    "reason": {"type": "string", "description": "Причина запроса"},
    "quantity": {"type": "number", "description": "Количество"},
    "equipment_type": {"type": "string", "description": "Тип оборудования"}
  }'),
(3, 'vacation-request', 'Заявка на отпуск', 'Заявка на ежегодный, учебный или административный отпуск', ARRAY['отпуск', 'кадры', 'отдых'],
 '{
    "end_date": {"type": "string", "description": "Дата окончания отпуска"},
    "start_date": {"type": "string", "description": "Дата начала отпуска"},
    "vacation_type": {"enum": ["ежегодный", "учебный", "без сохранения"], "type": "string", "description": "Тип отпуска"}
  }'),
(4, 'software-request', 'Заявка на закупку ПО', 'Заявка на приобретение лицензионного программного обеспечения', ARRAY['ПО', 'лицензии', 'закупка'],
 '{
    "reason": {"type": "string", "description": "Причина запроса"},
    "users_count": {"type": "number", "description": "Количество пользователей"},
    "license_type": {"enum": ["бессрочная", "подписка"], "type": "string", "description": "Тип лицензии"},
    "software_name": {"type": "string", "description": "Название программного обеспечения"}
  }'),
(5, 'remote-work-request', 'Заявка на удалённую работу', 'Заявка на временный или постоянный перевод на удалённый формат работы', ARRAY['удалёнка', 'remote', 'дистанционная работа'],
 '{
    "reason": {"type": "string", "description": "Причина запроса"},
    "end_date": {"type": "string", "description": "Дата окончания"},
    "start_date": {"type": "string", "description": "Дата начала"}
  }');

SELECT setval('templates_id_seq', 5);

INSERT INTO applications (id, created_at, applicant_id, template_slug, status, params, comment) VALUES
('app_001', '2025-05-12 06:15:00', 'emp_01', 'access-request', 'согласована', '{"reason": "Необходим доступ для разработки нового модуля отчётности", "resource": "PostgreSQL production", "access_level": "запись"}', 'Доступ предоставлен на 6 месяцев'),
('app_061', '2025-05-15 07:00:00', 'emp_04', 'software-request', 'согласована', '{"reason": "Для команды разработчиков", "users_count": 5, "license_type": "подписка", "software_name": "JetBrains All Products Pack"}', NULL),
('app_081', '2025-05-18 06:30:00', 'emp_01', 'remote-work-request', 'согласована', '{"reason": "Ремонт в квартире", "end_date": "2025-06-20", "start_date": "2025-05-20"}', NULL),
('app_021', '2025-05-20 06:00:00', 'emp_01', 'equipment-request', 'согласована', '{"reason": "Замена устаревшего оборудования", "quantity": 1, "equipment_type": "Ноутбук Lenovo ThinkPad X1 Carbon"}', 'Ноутбук выдан'),
('app_041', '2025-05-25 06:00:00', 'emp_01', 'vacation-request', 'согласована', '{"end_date": "2025-06-28", "start_date": "2025-06-15", "vacation_type": "ежегодный"}', NULL),
('app_020', '2025-05-28 08:00:00', 'emp_20', 'access-request', 'черновик', '{"reason": "Просмотр исходного кода для оценки сроков", "resource": "Bitbucket", "access_level": "чтение"}', NULL),
('app_060', '2025-05-30 13:00:00', 'emp_20', 'vacation-request', 'согласована', '{"end_date": "2025-06-25", "start_date": "2025-06-20", "vacation_type": "ежегодный"}', NULL),
('app_002', '2025-06-03 11:30:00', 'emp_03', 'access-request', 'согласована', '{"reason": "Настройка пайплайнов деплоя для микросервисов", "resource": "GitLab CI/CD", "access_level": "админ"}', NULL),
('app_091', '2025-06-05 08:30:00', 'emp_11', 'remote-work-request', 'согласована', '{"reason": "Серверное оборудование в процессе обновления", "end_date": "2025-07-10", "start_date": "2025-06-10"}', NULL),
('app_071', '2025-06-08 05:45:00', 'emp_05', 'software-request', 'согласована', '{"reason": "Управление тест-кейсами и отчётами", "users_count": 6, "license_type": "подписка", "software_name": "TestRail"}', NULL),
('app_042', '2025-06-10 08:30:00', 'emp_02', 'vacation-request', 'согласована', '{"end_date": "2025-07-14", "start_date": "2025-07-01", "vacation_type": "ежегодный"}', NULL),
('app_022', '2025-06-12 07:30:00', 'emp_02', 'equipment-request', 'согласована', '{"reason": "Увеличение рабочей области для разработки", "quantity": 1, "equipment_type": "Второй монитор Dell 27\""}', NULL),
('app_013', '2025-06-15 06:00:00', 'emp_10', 'access-request', 'согласована', '{"reason": "Управление инфраструктурой как кодом", "resource": "Terraform Cloud", "access_level": "админ"}', NULL),
('app_051', '2025-06-20 11:00:00', 'emp_11', 'vacation-request', 'согласована', '{"end_date": "2025-07-25", "start_date": "2025-07-15", "vacation_type": "ежегодный"}', NULL),
('app_062', '2025-06-22 11:30:00', 'emp_01', 'software-request', 'согласована', '{"reason": "Локальная разработка и тестирование контейнеров", "users_count": 3, "license_type": "подписка", "software_name": "Docker Desktop Pro"}', NULL),
('app_082', '2025-06-25 08:00:00', 'emp_02', 'remote-work-request', 'согласована', '{"reason": "Летний период, удобнее работать из дачи", "end_date": "2025-07-31", "start_date": "2025-07-01"}', NULL),
('app_031', '2025-06-28 08:45:00', 'emp_06', 'equipment-request', 'согласована', '{"reason": "Для параллельного запуска тестов и просмотра логов", "quantity": 1, "equipment_type": "Второй монитор LG 24\""}', NULL),
('app_023', '2025-07-05 11:00:00', 'emp_05', 'equipment-request', 'отклонена', '{"reason": "Удобство при работе", "quantity": 1, "equipment_type": "Игровая клавиатура"}', 'Отклонено: не соответствует политике закупок'),
('app_056', '2025-07-08 08:15:00', 'emp_08', 'vacation-request', 'согласована', '{"end_date": "2025-08-22", "start_date": "2025-08-15", "vacation_type": "ежегодный"}', NULL),
('app_083', '2025-07-10 11:00:00', 'emp_03', 'remote-work-request', 'отклонена', '{"reason": "Личные обстоятельства", "end_date": "2025-08-31", "start_date": "2025-08-01"}', 'Отклонено: испытательный период, необходимо присутствие в офисе'),
('app_036', '2025-07-12 06:00:00', 'emp_08', 'equipment-request', 'черновик', '{"reason": "Новый сотрудник", "quantity": 1, "equipment_type": "Ноутбук ThinkPad T14s"}', NULL),
('app_076', '2025-07-15 11:30:00', 'emp_06', 'software-request', 'согласована', '{"reason": "Кроссбраузерное тестирование", "users_count": 4, "license_type": "подписка", "software_name": "BrowserStack"}', NULL),
('app_003', '2025-07-18 07:00:00', 'emp_05', 'access-request', 'отклонена', '{"reason": "Тестирование автоматизированных скриптов мониторинга", "resource": "Production сервер", "access_level": "админ"}', 'Отклонено: доступ к production только через DevOps'),
('app_043', '2025-07-20 07:00:00', 'emp_05', 'vacation-request', 'согласована', '{"end_date": "2025-08-10", "start_date": "2025-08-01", "vacation_type": "ежегодный"}', NULL),
('app_096', '2025-07-22 07:00:00', 'emp_07', 'remote-work-request', 'согласована', '{"reason": "Автоматизация тестов, не требует офисного оборудования", "end_date": "2025-08-15", "start_date": "2025-08-01"}', NULL),
('app_018', '2025-07-25 11:45:00', 'emp_18', 'access-request', 'согласована', '{"reason": "Получение секретов для настройки серверов", "resource": "Vault", "access_level": "чтение"}', NULL),
('app_063', '2025-07-30 06:15:00', 'emp_07', 'software-request', 'отклонена', '{"reason": "Нагрузочное тестирование", "users_count": 1, "license_type": "бессрочная", "software_name": "LoadRunner"}', 'Отклонено: достаточно открытых аналогов'),
('app_004', '2025-08-02 08:45:00', 'emp_02', 'access-request', 'согласована', '{"reason": "Управление задачами проекта", "resource": "Jira", "access_level": "запись"}', NULL),
('app_084', '2025-08-05 07:15:00', 'emp_05', 'remote-work-request', 'согласована', '{"reason": "Семейные обстоятельства, переезд", "end_date": "2025-09-10", "start_date": "2025-08-10"}', NULL),
('app_072', '2025-08-05 13:00:00', 'emp_14', 'software-request', 'отклонена', '{"reason": "Бизнес-аналитика", "users_count": 3, "license_type": "подписка", "software_name": "Power BI Pro"}', 'Отклонено: используется Metabase'),
('app_044', '2025-08-10 11:15:00', 'emp_03', 'vacation-request', 'отклонена', '{"end_date": "2025-09-14", "start_date": "2025-09-01", "vacation_type": "ежегодный"}', 'Отклонено: дедлайн по проекту, перенести на октябрь'),
('app_024', '2025-08-15 08:15:00', 'emp_09', 'equipment-request', 'согласована', '{"reason": "Расширение кластера для тестовой среды", "quantity": 1, "equipment_type": "Сервер Dell PowerEdge R750"}', NULL),
('app_064', '2025-08-18 08:00:00', 'emp_13', 'software-request', 'согласована', '{"reason": "Визуализация данных для отчётов руководству", "users_count": 2, "license_type": "подписка", "software_name": "Tableau"}', NULL),
('app_092', '2025-08-20 05:30:00', 'emp_15', 'remote-work-request', 'черновик', '{"reason": "Высокая концентрация при удалённой работе", "end_date": "2025-09-30", "start_date": "2025-09-01"}', NULL),
('app_014', '2025-08-20 13:30:00', 'emp_15', 'access-request', 'черновик', '{"reason": "Создание аналитических отчётов", "resource": "Metabase", "access_level": "чтение"}', NULL),
('app_052', '2025-08-25 06:00:00', 'emp_14', 'vacation-request', 'черновик', '{"end_date": "2025-10-25", "start_date": "2025-10-15", "vacation_type": "ежегодный"}', NULL),
('app_032', '2025-08-30 13:00:00', 'emp_14', 'equipment-request', 'согласована', '{"reason": "Замена вышедшего из строя оборудования", "quantity": 1, "equipment_type": "Ноутбук ThinkPad X1 Carbon"}', NULL),
('app_085', '2025-09-01 06:00:00', 'emp_09', 'remote-work-request', 'согласована', '{"reason": "Работа из другого города временно", "end_date": "2025-12-15", "start_date": "2025-09-15"}', 'Разрешено до конца квартала'),
('app_037', '2025-09-05 07:30:00', 'emp_16', 'equipment-request', 'согласована', '{"reason": "Для работы с большими таблицами данных", "quantity": 1, "equipment_type": "Второй монитор Dell 27\""}', NULL),
('app_005', '2025-09-10 13:20:00', 'emp_09', 'access-request', 'согласована', '{"reason": "Управление облачной инфраструктурой", "resource": "AWS Console", "access_level": "админ"}', 'Предоставлен полный доступ к account'),
('app_073', '2025-09-12 09:30:00', 'emp_15', 'software-request', 'согласована', '{"reason": "Удобная работа с базой данных", "users_count": 2, "license_type": "бессрочная", "software_name": "dbForge Studio for PostgreSQL"}', NULL),
('app_045', '2025-09-15 05:45:00', 'emp_04', 'vacation-request', 'согласована', '{"end_date": "2025-10-10", "start_date": "2025-10-01", "vacation_type": "ежегодный"}', NULL),
('app_097', '2025-09-20 11:15:00', 'emp_08', 'remote-work-request', 'на согласовании', '{"reason": "Медицинские показания", "end_date": "2025-10-31", "start_date": "2025-10-01"}', NULL),
('app_025', '2025-09-22 06:45:00', 'emp_03', 'equipment-request', 'согласована', '{"reason": "Разработка iOS-приложения", "quantity": 1, "equipment_type": "Ноутбук MacBook Pro 16\""}', NULL),
('app_065', '2025-09-28 12:45:00', 'emp_09', 'software-request', 'согласована', '{"reason": "Аудит безопасности инфраструктуры", "users_count": 1, "license_type": "подписка", "software_name": "Nessus Professional"}', NULL),
('app_006', '2025-10-05 05:50:00', 'emp_13', 'access-request', 'на согласовании', '{"reason": "Аналитические запросы для отчётов руководству", "resource": "ClickHouse", "access_level": "чтение"}', NULL),
('app_086', '2025-10-10 12:30:00', 'emp_04', 'remote-work-request', 'согласована', '{"reason": "Командировка, удобнее работать удалённо", "end_date": "2025-11-15", "start_date": "2025-10-15"}', NULL),
('app_026', '2025-10-10 12:30:00', 'emp_07', 'equipment-request', 'согласована', '{"reason": "Для команды тестировщиков — концентрация при работе", "quantity": 5, "equipment_type": "Наушники Sony WH-1000XM5"}', 'Закуплено 5 комплектов'),
('app_066', '2025-10-15 10:00:00', 'emp_02', 'software-request', 'на согласовании', '{"reason": "Для работы с UI/UX дизайнерами", "users_count": 4, "license_type": "подписка", "software_name": "Figma Professional"}', NULL),
('app_015', '2025-10-18 09:15:00', 'emp_16', 'access-request', 'согласована', '{"reason": "Настройка дашбордов для бизнес-аналитики", "resource": "Redash", "access_level": "запись"}', NULL),
('app_046', '2025-10-20 09:00:00', 'emp_09', 'vacation-request', 'согласована', '{"end_date": "2025-11-07", "start_date": "2025-11-03", "vacation_type": "учебный"}', 'Учебный отпуск — защита сертификата'),
('app_033', '2025-10-25 05:15:00', 'emp_15', 'equipment-request', 'на согласовании', '{"reason": "Для проведения презентаций заказчику", "quantity": 1, "equipment_type": "Планшет iPad Pro"}', NULL),
('app_093', '2025-10-28 09:00:00', 'emp_16', 'remote-work-request', 'согласована', '{"reason": "Завершение аналитического отчёта", "end_date": "2025-11-30", "start_date": "2025-11-01"}', NULL),
('app_053', '2025-10-30 10:30:00', 'emp_15', 'vacation-request', 'согласована', '{"end_date": "2025-11-22", "start_date": "2025-11-15", "vacation_type": "ежегодный"}', NULL),
('app_074', '2025-11-05 07:00:00', 'emp_16', 'software-request', 'согласована', '{"reason": "Работа с несколькими БД одновременно", "users_count": 1, "license_type": "подписка", "software_name": "DataGrip"}', NULL),
('app_027', '2025-11-08 10:00:00', 'emp_13', 'equipment-request', 'на согласовании', '{"reason": "Текущий ноутбук не справляется с нагрузкой", "quantity": 1, "equipment_type": "Ноутбук ThinkPad T14"}', NULL),
('app_047', '2025-11-10 06:30:00', 'emp_06', 'vacation-request', 'на согласовании', '{"end_date": "2025-12-31", "start_date": "2025-12-20", "vacation_type": "ежегодный"}', NULL),
('app_087', '2025-11-15 10:00:00', 'emp_13', 'remote-work-request', 'на согласовании', '{"reason": "Зимний период, удалённая работа эффективнее", "end_date": "2026-01-31", "start_date": "2025-12-01"}', NULL),
('app_067', '2025-11-18 06:30:00', 'emp_11', 'software-request', 'согласована', '{"reason": "Тестирование на различных ОС", "users_count": 2, "license_type": "бессрочная", "software_name": "VMware Workstation Pro"}', NULL),
('app_007', '2025-11-22 10:10:00', 'emp_07', 'access-request', 'согласована', '{"reason": "Мониторинг ошибок при тестировании", "resource": "Sentry", "access_level": "чтение"}', NULL),
('app_057', '2025-11-25 06:00:00', 'emp_12', 'vacation-request', 'отклонена', '{"end_date": "2026-01-05", "start_date": "2025-12-25", "vacation_type": "ежегодный"}', 'Отклонено: праздничные дни уже нерабочие, сократить период'),
('app_028', '2025-12-01 07:00:00', 'emp_11', 'equipment-request', 'согласована', '{"reason": "Обновление сетевого оборудования", "quantity": 2, "equipment_type": "Коммутатор Cisco Catalyst 9300"}', NULL),
('app_048', '2025-12-05 12:00:00', 'emp_07', 'vacation-request', 'согласована', '{"end_date": "2026-01-12", "start_date": "2026-01-05", "vacation_type": "ежегодный"}', NULL),
('app_088', '2025-12-08 07:45:00', 'emp_06', 'remote-work-request', 'согласована', '{"reason": "Новогодние праздники, удобнее из дома", "end_date": "2026-01-15", "start_date": "2025-12-15"}', NULL),
('app_068', '2025-12-10 07:15:00', 'emp_17', 'software-request', 'согласована', '{"reason": "Управление проектами для всех команд", "users_count": 25, "license_type": "подписка", "software_name": "Jira Software Premium"}', NULL),
('app_008', '2025-12-14 06:30:00', 'emp_04', 'access-request', 'согласована', '{"reason": "Управление кластером для микросервисов", "resource": "Kubernetes Dashboard", "access_level": "админ"}', 'Доступ предоставлен'),
('app_077', '2025-12-15 08:45:00', 'emp_12', 'software-request', 'согласована', '{"reason": "Автоматизация управления серверами", "users_count": 3, "license_type": "подписка", "software_name": "Ansible Tower"}', NULL),
('app_039', '2025-12-20 12:45:00', 'emp_12', 'equipment-request', 'согласована', '{"reason": "Для удалённых сотрудников без проводного интернета", "quantity": 10, "equipment_type": "Кабель USB-C to Ethernet"}', NULL),
('app_089', '2026-01-05 06:00:00', 'emp_10', 'remote-work-request', 'согласована', '{"reason": "Температура в офисе ниже нормы", "end_date": "2026-02-10", "start_date": "2026-01-10"}', NULL),
('app_009', '2026-01-08 12:00:00', 'emp_11', 'access-request', 'согласована', '{"reason": "Настройка хранилища объектов для бэкапов", "resource": "MinIO", "access_level": "админ"}', NULL),
('app_049', '2026-01-10 07:15:00', 'emp_10', 'vacation-request', 'согласована', '{"end_date": "2026-02-08", "start_date": "2026-02-01", "vacation_type": "ежегодный"}', NULL),
('app_069', '2026-01-12 11:00:00', 'emp_03', 'software-request', 'черновик', '{"reason": "Тестирование API", "users_count": 8, "license_type": "подписка", "software_name": "Postman Team"}', NULL),
('app_029', '2026-01-15 11:20:00', 'emp_04', 'equipment-request', 'согласована', '{"reason": "Хранилище для резервных копий проектов", "quantity": 1, "equipment_type": "Внешний SSD Samsung T7 2TB"}', NULL),
('app_034', '2026-01-20 09:00:00', 'emp_17', 'equipment-request', 'согласована', '{"reason": "Для проведения собраний в переговорной", "quantity": 1, "equipment_type": "Проектор Epson"}', NULL),
('app_094', '2026-01-20 12:00:00', 'emp_17', 'remote-work-request', 'отклонена', '{"reason": "Управление распределённой командой", "end_date": "2026-03-01", "start_date": "2026-02-01"}', 'Отклонено: менеджер проектов должен присутствовать в офисе'),
('app_054', '2026-01-25 07:45:00', 'emp_16', 'vacation-request', 'согласована', '{"end_date": "2026-02-22", "start_date": "2026-02-15", "vacation_type": "ежегодный"}', NULL),
('app_010', '2026-01-25 07:45:00', 'emp_06', 'access-request', 'отклонена', '{"reason": "Создание тестовой документации", "resource": "Confluence", "access_level": "админ"}', 'Отклонено: достаточно прав на запись'),
('app_075', '2026-01-30 06:00:00', 'emp_18', 'software-request', 'на согласовании', '{"reason": "Мониторинг всей инфраструктуры", "users_count": 10, "license_type": "подписка", "software_name": "Prometheus + Grafana Enterprise"}', NULL),
('app_030', '2026-02-05 06:30:00', 'emp_10', 'equipment-request', 'отклонена', '{"reason": "Эргономика рабочего места", "quantity": 1, "equipment_type": "Стол электрический регулируемый"}', 'Отклонено: мебель закупается централизованно'),
('app_050', '2026-02-10 08:00:00', 'emp_13', 'vacation-request', 'согласована', '{"end_date": "2026-03-07", "start_date": "2026-03-01", "vacation_type": "без сохранения"}', 'Семейные обстоятельства'),
('app_090', '2026-02-12 11:30:00', 'emp_14', 'remote-work-request', 'согласована', '{"reason": "Работа над аналитическим проектом, нужна тишина", "end_date": "2026-03-15", "start_date": "2026-02-15"}', NULL),
('app_011', '2026-02-14 08:20:00', 'emp_14', 'access-request', 'согласована', '{"reason": "Мониторинг метрик для аналитических дашбордов", "resource": "Grafana", "access_level": "чтение"}', NULL),
('app_035', '2026-02-18 11:30:00', 'emp_19', 'equipment-request', 'согласована', '{"reason": "Защита серверного оборудования от скачков напряжения", "quantity": 2, "equipment_type": "UPS APC Smart-UPS 3000"}', NULL),
('app_070', '2026-02-22 08:30:00', 'emp_10', 'software-request', 'согласована', '{"reason": "Управление секретами в продакшене", "users_count": 5, "license_type": "подписка", "software_name": "HashiCorp Vault Enterprise"}', NULL),
('app_058', '2026-02-25 12:30:00', 'emp_18', 'vacation-request', 'согласована', '{"end_date": "2026-03-17", "start_date": "2026-03-10", "vacation_type": "учебный"}', NULL),
('app_098', '2026-02-28 08:00:00', 'emp_12', 'remote-work-request', 'согласована', '{"reason": "Внедрение системы мониторинга, удалённая настройка", "end_date": "2026-03-31", "start_date": "2026-03-01"}', NULL),
('app_012', '2026-02-28 11:00:00', 'emp_08', 'access-request', 'на согласовании', '{"reason": "Анализ логов при регрессионном тестировании", "resource": "ElasticSearch", "access_level": "чтение"}', NULL),
('app_078', '2026-03-01 10:15:00', 'emp_19', 'software-request', 'согласована', '{"reason": "Мониторинг сетевого оборудования", "users_count": 2, "license_type": "бессрочная", "software_name": "Nagios XI"}', NULL),
('app_016', '2026-03-05 05:30:00', 'emp_17', 'access-request', 'согласована', '{"reason": "Просмотр данных для управления проектами", "resource": "Portal (HR-система)", "access_level": "чтение"}', 'Доступ к HR-порталу'),
('app_095', '2026-03-08 06:45:00', 'emp_19', 'remote-work-request', 'согласована', '{"reason": "Настройка удалённого доступа к серверам", "end_date": "2026-04-10", "start_date": "2026-03-10"}', NULL),
('app_038', '2026-03-10 08:00:00', 'emp_18', 'equipment-request', 'отклонена', '{"reason": "Для зоны отдыха", "quantity": 1, "equipment_type": "Игровая приставка"}', 'Отклонено: не относится к рабочему оборудованию'),
('app_055', '2026-03-15 11:00:00', 'emp_17', 'vacation-request', 'на согласовании', '{"end_date": "2026-04-14", "start_date": "2026-04-01", "vacation_type": "ежегодный"}', NULL),
('app_017', '2026-03-20 07:00:00', 'emp_19', 'access-request', 'на согласовании', '{"reason": "Публикация внутренних образов контейнеров", "resource": "Docker Hub", "access_level": "запись"}', NULL),
('app_080', '2026-03-25 05:00:00', 'emp_20', 'software-request', 'согласована', '{"reason": "Создание диаграмм для документации проектов", "users_count": 5, "license_type": "подписка", "software_name": "Lucidchart"}', NULL),
('app_099', '2026-03-30 05:00:00', 'emp_18', 'remote-work-request', 'согласована', '{"reason": "Миграция сервисов, удалённая работа предпочтительнее", "end_date": "2026-04-30", "start_date": "2026-04-01"}', NULL),
('app_040', '2026-04-01 05:00:00', 'emp_20', 'equipment-request', 'на согласовании', '{"reason": "Для работы с iOS/macOS проектами", "quantity": 1, "equipment_type": "Ноутбук MacBook Air M3"}', NULL),
('app_059', '2026-04-05 05:30:00', 'emp_19', 'vacation-request', 'на согласовании', '{"end_date": "2026-05-10", "start_date": "2026-05-01", "vacation_type": "ежегодный"}', NULL),
('app_079', '2026-04-08 07:30:00', 'emp_08', 'software-request', 'отклонена', '{"reason": "Автоматизация UI-тестов", "users_count": 2, "license_type": "подписка", "software_name": "Selenium Grid Pro"}', 'Отклонено: открытой версии Selenium достаточно'),
('app_019', '2026-04-10 06:20:00', 'emp_12', 'access-request', 'отклонена', '{"reason": "Автоматизация синхронизации данных", "resource": "Реестр сотрудников", "access_level": "админ"}', 'Отклонено: реестр доступен только HR-отделу'),
('app_100', '2026-04-15 13:00:00', 'emp_20', 'remote-work-request', 'на согласовании', '{"reason": "Подготовка документации для нового проекта", "end_date": "2026-05-31", "start_date": "2026-05-01"}', NULL);
