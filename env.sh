# Optional shell setup for dots-plus. PATH only: library paths stay inside tsrun.
# shims/ comes first so that apt reaches tsapt. path/ comes last so that an installed
# program never replaces a system one.
_tsapt_dir="${TSAPT_DIR:-__TSAPT_DIR__}"
case ":$PATH:" in
  *":$_tsapt_dir/shims:"*) ;;
  *) PATH="$_tsapt_dir/shims:$_tsapt_dir/bin:$PATH:$_tsapt_dir/path" ;;
esac
export PATH
unset _tsapt_dir
