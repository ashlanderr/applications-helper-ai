# Помощник заявок

AI-чатбот для корпоративных сотрудников компании. Помогает найти и создать заявки (доступ к ресурсам, оборудование, отпуск, ПО, удалённая работа), задавая вопросы на естественном русском языке.

Проект экспериментальный. Данные в базе — моковые.

## Архитектура

```
┌─────────────┐     ┌─────────────┐     ┌──────────────┐
│   Браузер   │────▶│  Next.js 16 │────▶│  PostgreSQL  │
│   (React)   │◀────│  (App)      │◀────│     16       │
└─────────────┘     └──────┬──────┘     └──────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  Anthropic   │
                    │  Claude API  │
                    └──────────────┘
```

**Tech stack:**
- **Frontend:** Next.js 16, React 19, Tailwind CSS 4
- **Backend:** Next.js API Routes, Vercel AI SDK
- **AI:** Anthropic Claude (Anthropic SDK)
- **БД:** PostgreSQL 16 (pg.js)
- **Auth:** NextAuth.js 5 (JWT-сессии, пароль не проверяется)

## Быстрый старт

### Через Docker Compose (рекомендуется)

```bash
# 1. Клонируйте репозиторий
git clone <repo-url> && cd applications-helper-ai

# 2. Установите зависимости
npm install

# 3. Скопируйте переменные окружения
cp .env.example .env

# 4. Отредактируйте .env — вставьте ваш Anthropic API ключ

# 5. Запустите PostgreSQL через Docker
docker compose up -d db

# 6. Запустите приложение
npm run dev
```

Приложение: http://localhost:3000

База данных инициализируется автоматически при первом запуске Docker Compose.

### Ручная установка (без Docker)

```bash
# 1. Установите PostgreSQL 16 и создайте базу
createdb applications_db

# 2. Импортируйте схему и данные
psql -U postgres -d applications_db -f docker/init.sql

# 3. Установите зависимости
npm install

# 4. Скопируйте переменные окружения
cp .env.example .env

# 5. Отредактируйте .env

# 6. Запустите приложение
npm run dev
```

## Подключение

**Пользователи для входа:**

- `ivanov.as` - старый разработчик с заявками
- `artemov.ks` - новый разработчик без заявок
- любой другой сотрудник из БД

## Пример использования

1. Откройте http://localhost:3000 в браузере.
2. Войдите под логином `ivanov.as` или любым другим из базы данных.
3. В чате напишите один из запросов:
   - `"Покажи мои заявки"`
   - `"Создай заявку на доступ к GitLab"`
   - `"Какие заявки на оборудование были в этом месяце?"`
   - `"Создай заявку на отпуск с 1 по 14 июля"`
4. AI запросит недостающие данные и подготовит форму заявки

## Структура проекта

```
applications-helper-ai/
├── docker/
│   └── init.sql              # SQL-схема + мок-данные
├── src/
│   ├── app/
│   │   ├── api/
│   │   │   ├── auth/
│   │   │   │   └── [...nextauth]/
│   │   │   │       └── route.ts   # NextAuth.js API route
│   │   │   └── chat/
│   │   │       └── route.ts       # AI chat API endpoint
│   │   ├── chat/
│   │   │   └── page.tsx           # Страница чата
│   │   ├── login/
│   │   │   └── page.tsx           # Страница входа
│   │   ├── globals.css
│   │   ├── layout.tsx
│   │   └── page.tsx
│   ├── components/
│   │   ├── ApplicationForm.tsx    # Форма заявки
│   │   ├── ChatInterface.tsx      # Интерфейс чата
│   │   ├── Header.tsx
│   │   ├── LoginForm.tsx
│   │   ├── MarkdownRenderer.tsx
│   │   └── Providers.tsx
│   ├── lib/
│   │   ├── ai/
│   │   │   ├── prompts.ts         # Системный промпт для AI
│   │   │   └── tools.ts           # AI-инструменты (SQL-запросы, формы)
│   │   ├── auth/
│   │   │   └── config.ts          # Конфигурация NextAuth.js
│   │   └── db/
│   │       └── index.ts           # Пул соединений PostgreSQL
│   └── types/
│       └── index.ts
├── docker-compose.yml         # PostgreSQL + App сервисы
├── Dockerfile                 # Сборка приложения
├── .env.example               # Шаблон переменных окружения
├── next.config.ts
├── package.json
├── postcss.config.mjs
└── tsconfig.json
```

## База данных

### Таблицы

**departments** — отделы компании (5 шт.)

| Поле | Тип | Описание |
|------|-----|----------|
| id | SERIAL PK | Идентификатор |
| name | TEXT | Название отдела |

**employees** — сотрудники (21 шт.)

| Поле | Тип | Описание |
|------|-----|----------|
| id | TEXT PK | Идентификатор (emp_01, emp_02, ...) |
| full_name | TEXT | ФИО |
| department_id | INTEGER FK | Отдел |
| job_title | TEXT | Должность |
| login | TEXT | Логин для входа (lastname.initials) |

**templates** — шаблоны заявок (5 шт.)

| Поле | Тип | Описание |
|------|-----|----------|
| id | SERIAL PK | Идентификатор |
| slug | TEXT | Слаг (access-request, equipment-request, ...) |
| title | TEXT | Название |
| description | TEXT | Описание |
| tags | TEXT[] | Теги для поиска |
| params | JSONB | JSON-схема полей заявки |

**applications** — заявки (100 шт.)

| Поле | Тип | Описание |
|------|-----|----------|
| id | TEXT PK | Идентификатор (app_001, app_002, ...) |
| created_at | TIMESTAMP | Дата создания |
| applicant_id | TEXT FK | Сотрудник-заявитель |
| template_slug | TEXT FK | Тип заявки |
| status | TEXT | Статус (черновик / на согласовании / согласована / отклонена) |
| params | JSONB | Заполненные данные |
| comment | TEXT | Комментарий |

### Шаблоны заявок

| Слаг | Название | Поля |
|------|----------|------|
| `access-request` | Заявка на доступ к ресурсу | причина, ресурс, уровень доступа |
| `equipment-request` | Заявка на оборудование | причина, количество, тип оборудования |
| `vacation-request` | Заявка на отпуск | дата начала, дата окончания, тип отпуска |
| `software-request` | Заявка на закупку ПО | причина, количество пользователей, тип лицензии, название ПО |
| `remote-work-request` | Заявка на удалённую работу | причина, дата начала, дата окончания |

## Переменные окружения

Переменные задаются в файле `.env` (создайте из `.env.example`):

| Переменная | Описание | Пример |
|------------|----------|--------|
| `DATABASE_URL` | URL подключения к PostgreSQL | `postgresql://postgres:postgres@localhost:5432/applications_db` |
| `ANTHROPIC_API_KEY` | API-ключ Anthropic Claude | `sk-ant-...` |
| `AUTH_SECRET` | Секрет для JWT-сессий | `openssl rand -base64 32` |

## Технологии

- [Next.js 16](https://nextjs.org/) — React-фреймворк
- [React 19](https://react.dev/) — UI-библиотека
- [Tailwind CSS 4](https://tailwindcss.com/) — CSS-фреймворк
- [Vercel AI SDK](https://sdk.vercel.ai/) — AI-интеграция
- [Anthropic Claude](https://www.anthropic.com/) — LLM API
- [NextAuth.js 5](https://next-auth.js.org/) — аутентификация
- [PostgreSQL 16](https://www.postgresql.org/) — реляционная БД
- [pg.js](https://node-postgres.com/) — PostgreSQL-драйвер для Node.js
- [Docker](https://www.docker.com/) — контейнеризация БД
