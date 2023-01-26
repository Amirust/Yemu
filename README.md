### TCP Чат, Сервер на дарте
Не спрашивайте, мне просто нечего делать

### Чета типа документации
Для начала делаем `mv example.config.yaml config.yaml` и заполняем его <br>
Дальше пишем `dart run` и все

#### Типы запроса / ответа
**TCP СОКЕТ**
```dart
// Ответы сервера
enum ResponseTypes {
  Accepted,             // 0, { type: 0, data: { http: 'address:port / address / domain / null', publicKey: 'Ключ диффи-хелмана в хексе' } }
  AuthRequired,         // 1, { type: 1, data: '' }
  UserPasswordRequired, // 2, { type: 2, data: '' }
  InvalidPassword,      // 3, { type: 3, data: '' }
  AlreadyConnected,     // 4, { type: 4, data: '' }
  UserNotFound,         // 5, { type: 5, data: '' }
  UserMessage,          // 6, { type: 6, data: { user: '', message: '' } }
  UserAdd,              // 7, { type: 7, data: { user: '', allUsers: [''] } } allUsers - все пользователи в чате, массив никнеймов
  UserRemove,           // 8, { type: 8, data: { user: '' }
  AuthDataInvalid,      // 9, { type: 9, data: '' }
  MessageDataInvalid,   // 10, { type: 10, data: '' },
  UpdateAccessToken,    // 11, { type: 11, data: { accessToken: '' } }
  UserNotRegistered,    // 12, { type: 12, data: '' }
}

// Запросы клиента
enum RequestTypes {
  Auth,        // 0, { type: 0, data: { username: '', password: '', publicKey: '' } } password можно не передавать если сервер без регистрации (registration_required: false в конфиге)
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
Будешь писать клиент, вот тебе хуйня:
1. Шифрование построено на AES256 в CTR режиме, вектор инициализации - массив байтов длиной 16 байтов заполненых нулями, шифруется с помощью публичного ключа диффи-хеллмана, который передается вместе с запросом на авторизацию, дальше обрезается до 32 символов и уже обрезанный юзается для шифрования
2. При авторизации сервер выдаст ещё accessToken, который нужно будет юзать для HTTP запросов, иначе пошлёт нахуй. Он изменяется каждые 10 минут, так что не забудьте его обновлять, вам на сокет придет сообщение UpdateAccessToken с новым токеном

### Todo
- [X] Шифрование (AES + Diffie-Hellman)
- [X] Регистрация
- [ ] Клиент на флаттере (фронтенд говно ааа)
- [X] Требование ключа аутентификации для смены аватарки

Держите девочку <br>
![Isla](https://cdn.discordapp.com/attachments/1028379601921114136/1062778855758245928/21ad1a581f4f8c23270ad33d1487069a.jpg)
