Array.asArray = function(array) {
  if (Array.isArray(array)) {
    return array;
  }
  return array ? [array] : [];
};