<script>
import { debounce } from 'lodash';
import Editor from '~/editor/editor_lite';
import { CONTENT_UPDATE_DEBOUNCE } from '~/editor/constants';

function initEditorLite({ el, ...args }) {
  const editor = new Editor({
    scrollbar: {
      alwaysConsumeMouseWheel: false,
    },
  });

  return editor.createInstance({
    el,
    ...args,
  });
}

export default {
  inheritAttrs: false,
  props: {
    value: {
      type: String,
      required: false,
      default: '',
    },
    fileName: {
      type: String,
      required: false,
      default: '',
    },
    // This is used to help uniquely create a monaco model
    // even if two blob's share a file path.
    fileGlobalId: {
      type: String,
      required: false,
      default: '',
    },
    extensions: {
      type: [String, Array],
      required: false,
      default: () => null,
    },
    editorOptions: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    return {
      loading: true,
      editor: null,
    };
  },
  watch: {
    fileName(newVal) {
      this.editor.updateModelLanguage(newVal);
    },
  },
  mounted() {
    this.editor = initEditorLite({
      el: this.$refs.editor,
      blobPath: this.fileName,
      blobContent: this.value,
      blobGlobalId: this.fileGlobalId,
      extensions: this.extensions,
      ...this.editorOptions,
    });

    this.editor.onDidChangeModelContent(
      debounce(this.onFileChange.bind(this), CONTENT_UPDATE_DEBOUNCE),
    );
  },
  beforeDestroy() {
    this.editor.dispose();
  },
  methods: {
    onFileChange() {
      this.$emit('input', this.editor.getValue());
    },
  },
};
</script>
<template>
  <div class="file-content code">
    <div id="editor" ref="editor" data-editor-loading @editor-ready="$emit('editor-ready')">
      <pre class="editor-loading-content">{{ value }}</pre>
    </div>
  </div>
</template>
