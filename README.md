### TCP Чат, Сервер на дарте
Не спрашивайте, мне просто нечего делать

### Чета типа документации
Для начала делаем `mv example.config.yaml config.yaml` и заполняем его <br>
Дальше пишем `dart run` и все

Типы запроса / ответа **TCP СОКЕТ**
```dart
// Ответы сервера
enum ResponseTypes {
  Accepted,             // 0, { type: 0, data: { httpPort: 3073 || null } } HTTP порт может быть null, если http_enabled: false в конфиге
  AuthRequired,         // 1, { type: 1, data: '' }
  UserPasswordRequired, // 2, { type: 2, data: '' }
  InvalidPassword,      // 3, { type: 3, data: '' }
  AlreadyConnected,     // 4, { type: 4, data: '' }
  UserNotFound,         // 5, { type: 5, data: '' }
  UserMessage,          // 6, { type: 6, data: { user: '', message: '' } }
  UserAdd,              // 7, { type: 7, data: { user: '', allUsers: [''] } } allUsers - все пользователи в чате, массив никнеймов
  UserRemove            // 8, { type: 8, data: { user: '' }
}

// Запросы клиента
enum RequestTypes {
  Auth,        // 0, { type: 0, data: { username: '', password: '' } } password можно не передавать если сервер без регистрации (registration_required: false в конфиге)
  UserMessage, // 1, { type: 1, data: { message: '' } }
}
```
**HTTP**
```http request
// Получить картинку
GET /images/:image

// Загрузить картинку, вернет { file: 'image.png / etc' }
POST /images/:image
Form data:
  image: file
  username: text

// Получить аватарку, вернет картинку или 404 если нету
GET /user/:username/avatar

// Загрузить аватарку, вернет Avatar uploaded если все хорошо
POST /user/:username/avatar
Form data:
  avatar: file
```

### Хрень
Ликуйте пока я не добавил шифрование, будет разрыв очка боль <br>

### Todo
- [ ] Шифрование
- [ ] Регистрация
- [ ] Клиент на флаттере (фронтенд говно ааа)

Держите девочку <br>
![Isla](https://cdn.discordapp.com/attachments/1028379601921114136/1062778855758245928/21ad1a581f4f8c23270ad33d1487069a.jpg)
