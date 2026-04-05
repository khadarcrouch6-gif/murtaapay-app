import {getRequestConfig} from 'next-intl/server';
import {routing} from './routing';
import fs from 'fs';
import path from 'path';

export default getRequestConfig(async ({requestLocale}) => {
  let locale = await requestLocale;
 
  // Ensure that a valid locale is used
  if (!locale || !routing.locales.includes(locale as any)) {
    locale = routing.defaultLocale;
  }

  // Use fs.readFileSync to bypass Next.js module cache so changes
  // to message files are picked up without a server restart in dev mode
  const messagesPath = path.join(process.cwd(), 'messages', `${locale}.json`);
  const messages = JSON.parse(fs.readFileSync(messagesPath, 'utf-8'));
 
  return {
    locale,
    messages
  };
});
