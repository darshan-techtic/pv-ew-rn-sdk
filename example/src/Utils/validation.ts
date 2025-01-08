export const isTextNotEmpty = (text: string) => {
  if (text && text.trim().length > 0) {
    return true;
  }
  return false;
};

export const validateEmail = (email: string) => {
  const emailRegex =
    /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  email = email.trim();
  if (emailRegex.test(email)) {
    return true;
  }
  return false;
};
