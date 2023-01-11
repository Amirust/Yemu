enum ResponseTypes {
  Accepted,
  AuthRequired,
  UserPasswordRequired,
  InvalidPassword,
  AlreadyConnected,
  UserNotFound,

  UserMessage,
  UserAdd,
  UserRemove
}

const Map<ResponseTypes, String> ResponseDescription = {
  ResponseTypes.Accepted: 'Accepted',
  ResponseTypes.AuthRequired: 'Auth required',
  ResponseTypes.UserPasswordRequired: 'User password required',
  ResponseTypes.InvalidPassword: 'Invalid password',
  ResponseTypes.AlreadyConnected: 'User with this nickname or ip address already connected',
  ResponseTypes.UserNotFound: 'User not found',
  ResponseTypes.UserMessage: 'User message',
  ResponseTypes.UserAdd: 'User add',
  ResponseTypes.UserRemove: 'User remove',
};