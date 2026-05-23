export const parseImpl = (text) => () => JSON.parse(text);

export const stringifyImpl = (value) => (indent) => () => JSON.stringify(value, null, indent);

export const getStringFieldImpl = (key) => (obj) => obj[key];

export const setStringFieldImpl = (key) => (value) => (obj) => () => {
  obj[key] = value;
};
