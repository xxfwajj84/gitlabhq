import AjaxCache from '~/lib/utils/ajax_cache';

const REGEX_QUICK_ACTIONS = /^\/\w+.*$/gm;

export const findNoteObjectById = (notes, id) => notes.filter(n => n.id === id)[0];

export const getQuickActionText = note => {
  let text = 'Applying command';
  const quickActions = AjaxCache.get(gl.GfmAutoComplete.dataSources.commands) || [];

  const executedCommands = quickActions.filter(command => {
    const commandRegex = new RegExp(`/${command.name}`);
    return commandRegex.test(note);
  });

  if (executedCommands && executedCommands.length) {
    if (executedCommands.length > 1) {
      text = 'Applying multiple commands';
    } else {
      const commandDescription = executedCommands[0].description.toLowerCase();
      text = `Applying command to ${commandDescription}`;
    }
  }

  return text;
};

export const reduceDiscussionsToLineCodes = selectedDiscussions =>
  selectedDiscussions.reduce((acc, note) => {
    if (note.diff_discussion && note.line_code && note.resolvable) {
      // For context about line notes: there might be multiple notes with the same line code
      const items = acc[note.line_code] || [];
      if (note.diff_file) {
        Object.assign(note, { fileHash: note.diff_file.file_hash });
        // delete note.diff_file;
      }

      items.push(note);

      Object.assign(acc, { [note.line_code]: items });
    }
    return acc;
  }, {});

export const hasQuickActions = note => REGEX_QUICK_ACTIONS.test(note);

export const stripQuickActions = note => note.replace(REGEX_QUICK_ACTIONS, '').trim();
