enum ResponseTypes {
  Accepted,
  AuthRequired,
  UserPasswordRequired,
  InvalidPassword,
  AlreadyConnected,
  UserNotFound,

  UserMessage,
  UserAdd,
  UserRemove,
  AuthDataInvalid,
  MessageDataInvalid,
  UpdateAccessToken,
  UserNotRegistered
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
  ResponseTypes.AuthDataInvalid: 'Auth data invalid',
  ResponseTypes.MessageDataInvalid: 'Message data invalid',
  ResponseTypes.UpdateAccessToken: 'Update access token',
  ResponseTypes.UserNotRegistered: 'User not registered'
};