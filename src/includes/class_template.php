<?php
/**
 * SKYUC! 模板类,模拟smarty模板
 * ============================================================================
 * 版权所有 (C) 2012 天空网络，并保留所有权利。
 * 网站地址: http://www.skyuc.com
 * ----------------------------------------------------------------------------
 * This is NOT a freeware, use is subject to license terms
 * ============================================================================
 */
class Template
{
    public $template_dir = ''; //模板目录
    public $cache_dir = ''; //缓存目录
    public $compile_dir = ''; //编译目录
    public $cache_lifetime = 3600; // 缓存更新时间, 默认 1 天
    public $direct_output = false; // 直接输出
    public $caching = false; // 缓存
    public $template = array();
    public $force_compile = false; // 强制编译
    public $_var = array();
    public $_schash = '554fcae493e564ee0dc75bdf2ebf94ca';
    public $_foreach = array();
    public $_current_file = '';
    public $_expires = 0;
    public $_errorlevel = 0;
    public $_nowtime = null;
    public $_checkfile = true;
    public $_foreachmark = '';
    public $_seterror = 0;
    public $_temp_key = array(); // 临时存放 foreach 里 key 的数组
    public $_temp_val = array(); // 临时存放 foreach 里 item 的数组
    public function __construct()
    {
        $this->_errorlevel = error_reporting();
        $this->_nowtime = time();
        if (empty($GLOBALS['db']->explain)) {
            header('Content-type: text/html; charset=utf-8');
        }
    }

    /**
     * 注册变量
     *
     * @access  public
     * @param   mix      $tpl_var
     * @param   mix      $value
     *
     * @return  void
     */
    public function assign($tpl_var, $value = '')
    {
        if (is_array($tpl_var)) {
            foreach ($tpl_var as $key => $val) {
                if ($key != '') {
                    $this->_var[$key] = $val;
                }
            }
        } else {
            if ($tpl_var != '') {
                $this->_var[$tpl_var] = $value;
            }
        }
    }

    /**
     * 显示页面函数
     *
     * @access  public
     * @param   string      $filename
     * @param   sting      $cache_id
     *
     * @return  void
     */
    public function display($filename, $cache_id = '')
    {
        $this->_seterror++;
        error_reporting(E_ALL ^ E_NOTICE);
        $this->_checkfile = false;
        $output = $this->fetch($filename, $cache_id);
        if (strpos($output, $this->_schash) !== false) {
            $k = explode($this->_schash, $output);
            foreach ($k as $key => $val) {
                if (($key % 2) == 1) {
                    $k[$key] = $this->insert_mod($val);
                }
            }
            $output = implode('', $k);
        }
        error_reporting($this->_errorlevel);
        $this->_seterror--;
        //数据调试
        if ($GLOBALS['skyuc']->db->explain) {
            $totaltime = microtime(true) - TIMESTART;
            $vartext = "<!-- Page generated in " .
                       skyuc_number_format($totaltime, 5) . " seconds with " .
                       $GLOBALS['skyuc']->db->querycount . " queries -->";
            $querytime = $GLOBALS['skyuc']->db->time_total;
            echo "\n<b>Page generated in $totaltime seconds with " .
                 $GLOBALS['skyuc']->db->queryCount .
                 " queries,\nspending $querytime doing MySQL queries and " .
                 ($totaltime - $querytime) .
                 " doing PHP things.\n\n<hr />Shutdown Queries:</b>" .
                 (defined('NOSHUTDOWNFUNC') ? " <b>DISABLED</b>"
                         : '') . "<hr />\n\n";
            exit();
        }
        //开始Gzip压缩
        if ($GLOBALS['skyuc']->options['gzipoutput'] && !headers_sent() &&
            THIS_SCRIPT != 'player'
        ) {
            $output = fetch_gzipped_text($output,
                                         $GLOBALS['skyuc']->options['gziplevel']);
            if ($GLOBALS['skyuc']->donegzip) {
                @header('Content-Length: ' . strlen($output));
            }
        }
        //执行关闭脚本
        exec_shut_down();
        echo $output;
    }

    /**
     * 处理模板文件
     *
     * @access  public
     * @param   string      $filename
     * @param   sting      $cache_id
     *
     * @return  sring
     */
    public function fetch($filename, $cache_id = '')
    {
        if (!$this->_seterror) {
            error_reporting(E_ALL ^ E_NOTICE);
        }
        $this->_seterror++;
        if (strncmp($filename, 'str:', 4) == 0) {
            $out = $this->_eval($this->fetch_str(substr($filename, 4)));
        } else {
            //缓存名称
            $cachename = basename($filename,
                                  strrchr($filename, '.')) . '_' . $cache_id;
            $key = md5($cachename);
            $item = ($filename === 'show.dwt' || $filename === 'list.dwt')
                    ? $key : $filename;
            $GLOBALS['skyuc']->secache->setModified($item, true);
            if ($this->_checkfile) {
                if (!file_exists($filename)) {
                    $filename = $this->template_dir . '/' . $filename;
                }
            } else {
                $filename = $this->template_dir . '/' . $filename;
            }
            if ($this->direct_output) {
                $this->_current_file = $filename;
                $out = $this->_eval(
                    $this->fetch_str(file_get_contents($filename)));
            } else {
                if ($cache_id && $this->caching) {
                    $out = $this->template_out;
                } else {
                    if (!in_array($filename, $this->template)) {
                        $this->template[] = $filename;
                    }
                    $out = $this->make_compiled($filename);
                    if ($cache_id) {
                        $data = serialize(
                            array('template' => $this->template,
                                 'expires' => $this->_nowtime + $this->cache_lifetime,
                                 'maketime' => $this->_nowtime));
                        $out = str_replace("\r", '', $out);
                        while (strpos($out, "\n\n") !== false) {
                            $out = str_replace("\n\n", "\n", $out);
                        }
                        // 缓存文件
                        if ($GLOBALS['skyuc']->secache->store(
                                $key, $data . $out) === false
                        ) {
                            trigger_error(
                                'can\'t write:' . $key . ' ' . $cachename);
                        }
                        $this->template = array();
                    }
                }
            }
        }
        $this->_seterror--;
        if (!$this->_seterror) {
            error_reporting($this->_errorlevel);
        }
        return $out; // 返回html数据
    }

    /**
     * 编译模板函数
     *
     * @access  public
     * @param   string      $filename
     *
     * @return  sring        编译后文件地址
     */
    public function make_compiled($filename)
    {
        $name = $this->compile_dir . '/' . basename($filename) . '.php';
        if ($this->_expires) {
            $expires = $this->_expires - $this->cache_lifetime;
        } else {
            $filestat = @stat($name);
            $expires = $filestat['mtime'];
        }
        $filestat = @stat($filename);
        if ($filestat['mtime'] <= $expires && !$this->force_compile) {
            if (file_exists($name)) {
                $source = $this->_require($name);
                if ($source == '') {
                    $expires = 0;
                }
            } else {
                $source = '';
                $expires = 0;
            }
        }
        if ($this->force_compile || $filestat['mtime'] > $expires) {
            $this->_current_file = $filename;
            $source = $this->fetch_str(file_get_contents($filename));
            if (file_put_contents($name, $source, LOCK_EX) === false) {
                trigger_error('can\'t write:' . $name);
            }
            $source = $this->_eval($source);
        }
        return $source;
    }

    /**
     * 处理字符串函数
     *
     * @access  public
     * @param   string     $source
     *
     * @return  sring
     */
    public function fetch_str($source)
    {
        if (!defined('IN_CONTROL_PANEL')) {
            $source = $this->smarty_prefilter_preCompile($source);
        }
        $source = preg_replace("/<\?[^><]+\?>/i", "", $source);
        return preg_replace("/{([^\}\{\n]*)}/e", "\$this->select('\\1');",
                            $source);
    }

    /**
     * 判断是否缓存
     *
     * @access  public
     * @param   string     $filename
     * @param   sting      $cache_id
     *
     * @return  bool
     */
    public function is_cached($filename, $cache_id = '')
    {
        $cachename = basename($filename, strrchr($filename, '.')) . '_' .
                     $cache_id;
        if ($this->caching == true && $this->direct_output == false) {
            global $skyuc;
            $key = md5($cachename);
            //读取缓存
            if ($skyuc->secache->fetch($key, $data)) {
                $pos = strpos($data, '<');
                $paradata = substr($data, 0, $pos);
                $para = @unserialize($paradata);
                $item = ($filename === 'show.dwt' || $filename === 'list.dwt')
                        ? $key : $filename;
                if ($skyuc->secache->getModified($item)) {
                    $para['expires'] = $skyuc->secache->getModified($item);
                }
                if ($para === false || $this->_nowtime > $para['expires']) {
                    $this->caching = false;
                    return false;
                }
                $this->_expires = $para['expires'];
                $this->template_out = substr($data, $pos);
                foreach ($para['template'] as $val) {
                    $stat = @stat($val);
                    if ($para['maketime'] < $stat['mtime']) {
                        $this->caching = false;
                        return false;
                    }
                }
            } else {
                $this->caching = false;
                return false;
            }
            return true;
        } else {
            return false;
        }
    }

    /**
     * 处理{}标签
     *
     * @access  public
     * @param   string      $tag
     *
     * @return  sring
     */
    public function select($tag)
    {
        $tag = stripslashes(trim($tag));
        if (empty($tag)) {
            return '{}';
        } elseif ($tag{0} == '*' && substr($tag, -1) == '*') { // 注释部分
            return '';
        } elseif ($tag{0} == '$') { // 变量
            return '<?php echo ' . $this->get_val(substr($tag, 1)) .
                   '; ?>';
        } elseif ($tag{0} == '/') { // 结束 tag
            switch (substr($tag, 1)) {
                case 'if':
                    return '<?php endif; ?>';
                    break;
                case 'foreach':
                    if ($this->_foreachmark == 'foreachelse') {
                        $output = '<?php endif; unset($_from); ?>';
                    } else {
                        array_pop($this->_patchstack);
                        $output = '<?php endforeach; endif; unset($_from);?>';
                    }
                    $output .= "<?php \$this->pop_vars();; ?>";
                    return $output;
                    break;
                case 'literal':
                    return '';
                    break;
                case 'php': //PHP语句结束{/php}标签
                    return '?>';
                    break;
                default:
                    return '{' . $tag . '}';
                    break;
            }
        } else {
            $tag_sel = array_shift(explode(' ', $tag));
            switch ($tag_sel) {
                case 'if':
                    return $this->_compile_if_tag(substr($tag, 3));
                    break;
                case 'else':
                    return '<?php else: ?>';
                    break;
                case 'elseif':
                    return $this->_compile_if_tag(substr($tag, 7), true);
                    break;
                case 'foreachelse':
                    $this->_foreachmark = 'foreachelse';
                    return '<?php endforeach; else: ?>';
                    break;
                case 'foreach':
                    $this->_foreachmark = 'foreach';
                    if (!isset($this->_patchstack)) {
                        $this->_patchstack = array();
                    }
                    return $this->_compile_foreach_start(substr($tag, 8));
                    break;
                case 'assign':
                    $t = $this->get_para(substr($tag, 7), 0);
                    if ($t['value']{0} == '$') {
                        /* 如果传进来的值是变量，就不用用引号 */
                        $tmp = '$this->assign(\'' . $t['var'] . '\',' .
                               $t['value'] . ');';
                    } else {
                        $tmp = '$this->assign(\'' . $t['var'] . '\',\'' .
                               addcslashes($t['value'], "'") . '\');';
                    }
                    // $tmp = $this->assign($t['var'], $t['value']);
                    return '<?php ' . $tmp . ' ?>';
                    break;
                case 'include':
                    $t = $this->get_para(substr($tag, 8), 0);
                    return '<?php echo $this->fetch(' . "'$t[file]'" . '); ?>';
                    break;
                case 'insert_scripts':
                    $t = $this->get_para(substr($tag, 15), 0);
                    return '<?php echo $this->smarty_insert_scripts(' .
                           $this->make_array($t) . '); ?>';
                    break;
                case 'create_pages':
                    $t = $this->get_para(substr($tag, 13), 0);
                    return '<?php echo $this->smarty_create_pages(' .
                           $this->make_array($t) . '); ?>';
                    break;
                case 'php': //PHP语句开始,{php}标签
                    return '<?php ';
                    break;
                case 'insert':
                    $t = $this->get_para(substr($tag, 7), false);
                    $out = "<?php \n" . '$k = ' . preg_replace(
                        "/(\'\\$[^,]+)/e", "stripslashes(trim('\\1','\''));",
                        var_export($t, true)) . ";\n";
                    $out .= 'echo $this->_schash . $k[\'name\'] . \'|\' . serialize($k) . $this->_schash;' .
                            "\n?>";
                    return $out;
                    break;
                case 'literal':
                    return '';
                    break;
                case 'cycle':
                    $t = $this->get_para(substr($tag, 6), 0);
                    return '<?php echo $this->cycle(' . $this->make_array($t) .
                           '); ?>';
                    break;
                case 'html_options':
                    $t = $this->get_para(substr($tag, 13), 0);
                    return '<?php echo $this->html_options(' .
                           $this->make_array($t) . '); ?>';
                    break;
                case 'html_select_date':
                    $t = $this->get_para(substr($tag, 17), 0);
                    return '<?php echo $this->html_select_date(' .
                           $this->make_array($t) . '); ?>';
                    break;
                case 'html_radios':
                    $t = $this->get_para(substr($tag, 12), 0);
                    return '<?php echo $this->html_radios(' .
                           $this->make_array($t) . '); ?>';
                    break;
                case 'html_checkboxes':
                    $t = $this->get_para(substr($tag, 12), 0);
                    return '<?php echo $this->html_checkboxes(' .
                           $this->make_array($t) . '); ?>';
                    break;
                case 'html_select_time':
                    $t = $this->get_para(substr($tag, 12), 0);
                    return '<?php echo $this->html_select_time(' .
                           $this->make_array($t) . '); ?>';
                    break;
                default:
                    return '{' . $tag . '}';
                    break;
            }
        }
    }

    /**
     * 处理smarty标签中的变量标签
     *
     * @access  public
     * @param   string     $val
     *
     * @return  bool
     */
    public function get_val($val)
    {
        if (strrpos($val, '[') !== false) {
            $val = preg_replace("/\[([^\[\]]*)\]/eis",
                                "'.'.str_replace('$','\$','\\1')", $val);
        }
        if (strrpos($val, '|') !== false) {
            $moddb = explode('|', $val);
            $val = array_shift($moddb);
        }
        if (empty($val)) {
            return '';
        }
        if (strpos($val, '.$') !== false) {
            $all = explode('.$', $val);
            foreach ($all as $key => $val) {
                $all[$key] = $key == 0 ? $this->make_var($val) : '[' .
                                                                 $this->make_var($val) . ']';
            }
            $p = implode('', $all);
        } else {
            $p = $this->make_var($val);
        }
        if (!empty($moddb)) {
            foreach ($moddb as $key => $mod) {
                $s = explode(':', $mod);
                switch ($s[0]) {
                    case 'escape':
                        $s[1] = trim($s[1], '"');
                        if ($s[1] == 'html') {
                            $p = 'htmlspecialchars(' . $p . ')';
                        } elseif ($s[1] == 'url') {
                            $p = 'urlencode(' . $p . ')';
                        } elseif ($s[1] == 'decode_url') {
                            $p = 'urldecode(' . $p . ')';
                        } elseif ($s[1] == 'quotes') {
                            $p = 'strtr(' . $p . ',array(\'"\'=>\'&quot;\'))';
                        } else {
                            $p = 'htmlspecialchars(' . $p . ')';
                        }
                        break;
                    case 'nl2br':
                        $p = 'nl2br(' . $p . ')';
                        break;
                    case 'default':
                        $s[1] = $s[1]{0} == '$' ? $this->get_val(
                            substr($s[1], 1)) : "'$s[1]'";
                        $p = 'empty(' . $p . ') ? ' . $s[1] . ' : ' . $p;
                        break;
                    case 'truncate':
                        if (empty($s[2])) {
                            $p = 'sub_str(' . $p . ",$s[1],false)";
                        } else {
                            $p = 'sub_str(' . $p . ",$s[1],true)";
                        }
                        break;
                    case 'strip_tags':
                        $p = 'strip_tags(' . $p . ')';
                        break;
                    default:
                        # code...
                        break;
                }
            }
        }
        return $p;
    }

    /**
     * 处理去掉$的字符串
     *
     * @access  public
     * @param   string     $val
     *
     * @return  bool
     */
    public function make_var($val)
    {
        if (strrpos($val, '.') === false) {
            if (isset($this->_var[$val]) && isset($this->_patchstack[$val])) {
                $val = $this->_patchstack[$val];
            }
            $p = '$this->_var[\'' . $val . '\']';
        } else {
            $t = explode('.', $val);
            $_var_name = array_shift($t);
            if (isset($this->_var[$_var_name]) &&
                isset($this->_patchstack[$_var_name])
            ) {
                $_var_name = $this->_patchstack[$_var_name];
            }
            if ($_var_name == 'smarty') {
                $p = $this->_compile_smarty_ref($t);
            } else {
                $p = '$this->_var[\'' . $_var_name . '\']';
            }
            foreach ($t as $val) {
                $p .= '[\'' . $val . '\']';
            }
        }
        return $p;
    }

    /**
     * 处理insert外部函数/需要include运行的函数的调用数据
     *
     * @access  public
     * @param   string     $val
     * @param   int         $type
     *
     * @return  array
     */
    public function get_para($val, $type = 1) // 处理insert外部函数/需要include运行的函数的调用数据
    {
        $pa = $this->str_trim($val);
        foreach ($pa as $value) {
            if (strrpos($value, '=')) {
                list ($a, $b) = explode('=',
                                        str_replace(array(' ', '"', "'", '&quot;'), '', $value));
                if ($b{0} == '$') {
                    if ($type) {
                        eval(
                                '$para[\'' . $a . '\']=' . $this->get_val(substr($b, 1)) .
                                ';');
                    } else {
                        $para[$a] = $this->get_val(substr($b, 1));
                    }
                } else {
                    $para[$a] = $b;
                }
            }
        }
        return $para;
    }

    /**
     * 判断变量是否被注册并返回值
     *
     * @access  public
     * @param   string     $name
     *
     * @return  mix
     */
    public function &get_template_vars($name = null)
    {
        if (empty($name)) {
            return $this->_var;
        } elseif (!empty($this->_var[$name])) {
            return $this->_var[$name];
        } else {
            $_tmp = null;
            return $_tmp;
        }
    }

    /**
     * 处理if标签
     *
     * @access  public
     * @param   string     $tag_args
     * @param   bool       $elseif
     *
     * @return  string
     */
    public function _compile_if_tag($tag_args, $elseif = false)
    {
        preg_match_all(
            '/\-?\d+[\.\d]+|\'[^\'|\s]*\'|"[^"|\s]*"|[\$\w\.]+|!==|===|==|!=|<>|<<|>>|<=|>=|&&|\|\||\(|\)|,|\!|\^|=|&|<|>|~|\||\%|\+|\-|\/|\*|\@|\S/',
            $tag_args, $match);
        $tokens = $match[0];
        // make sure we have balanced parenthesis
        $token_count = array_count_values($tokens);
        if (!empty($token_count['(']) && $token_count['('] != $token_count[')']) {
            // $this->_syntax_error('unbalanced parenthesis in if statement', E_USER_ERROR, __FILE__, __LINE__);
        }
        for ($i = 0, $count = count($tokens); $i < $count; $i++) {
            $token = &$tokens[$i];
            switch (strtolower($token)) {
                case 'eq':
                    $token = '==';
                    break;
                case 'ne':
                case 'neq':
                    $token = '!=';
                    break;
                case 'lt':
                    $token = '<';
                    break;
                case 'le':
                case 'lte':
                    $token = '<=';
                    break;
                case 'gt':
                    $token = '>';
                    break;
                case 'ge':
                case 'gte':
                    $token = '>=';
                    break;
                case 'and':
                    $token = '&&';
                    break;
                case 'or':
                    $token = '||';
                    break;
                case 'not':
                    $token = '!';
                    break;
                case 'mod':
                    $token = '%';
                    break;
                default:
                    if ($token[0] == '$') {
                        $token = $this->get_val(substr($token, 1));
                    }
                    break;
            }
        }
        if ($elseif) {
            return '<?php elseif (' . implode(' ', $tokens) . '): ?>';
        } else {
            return '<?php if (' . implode(' ', $tokens) . '): ?>';
        }
    }

    /**
     * 处理foreach标签
     *
     * @access  public
     * @param   string     $tag_args
     *
     * @return  string
     */
    public function _compile_foreach_start($tag_args)
    {
        $attrs = $this->get_para($tag_args, 0);
        $arg_list = array();
        $from = $attrs['from'];
        if (isset($this->_var[$attrs['item']]) &&
            !isset($this->_patchstack[$attrs['item']])
        ) {
            $this->_patchstack[$attrs['item']] = $attrs['item'] . '_' .
                                                 str_replace(array(' ', '.'), '_', microtime());
            $attrs['item'] = $this->_patchstack[$attrs['item']];
        } else {
            $this->_patchstack[$attrs['item']] = $attrs['item'];
        }
        $item = $this->get_val($attrs['item']);
        if (!empty($attrs['key'])) {
            $key = $attrs['key'];
            $key_part = $this->get_val($key) . ' => ';
        } else {
            $key = null;
            $key_part = '';
        }
        if (!empty($attrs['name'])) {
            $name = $attrs['name'];
        } else {
            $name = null;
        }
        $output = '<?php ';
        $output .= "\$_from = $from; if (!is_array(\$_from) && !is_object(\$_from)) { settype(\$_from, 'array'); }; \$this->push_vars('$attrs[key]', '$attrs[item]');";
        if (!empty($name)) {
            $foreach_props = "\$this->_foreach['$name']";
            $output .= "{$foreach_props} = array('total' => count(\$_from), 'iteration' => 0);\n";
            $output .= "if ({$foreach_props}['total'] > 0):\n";
            $output .= "    foreach (\$_from AS $key_part$item):\n";
            $output .= "        {$foreach_props}['iteration']++;\n";
        } else {
            $output .= "if (count(\$_from)):\n";
            $output .= "    foreach (\$_from AS $key_part$item):\n";
        }
        return $output . '?>';
    }

    /**
     * 将 foreach 的 key, item 放入临时数组
     *
     * @param  mixed    $key
     * @param  mixed    $val
     *
     * @return  void
     */
    public function push_vars($key, $val)
    {
        if (!empty($key)) {
            array_push($this->_temp_key,
                       "\$this->_vars['$key']='" . $this->_vars[$key] . "';");
        }
        if (!empty($val)) {
            array_push($this->_temp_val,
                       "\$this->_vars['$val']='" . $this->_vars[$val] . "';");
        }
    }

    /**
     * 弹出临时数组的最后一个
     *
     * @return  void
     */
    public function pop_vars()
    {
        $key = array_pop($this->_temp_key);
        $val = array_pop($this->_temp_val);
        if (!empty($key)) {
            eval($key);
        }
    }

    /**
     * 处理smarty开头的预定义变量
     *
     * @access  public
     * @param   array   $indexes
     *
     * @return  string
     */
    public function _compile_smarty_ref(&$indexes)
    {
        /* Extract the reference name. */
        $_ref = $indexes[0];
        switch ($_ref) {
            case 'now':
                $compiled_ref = 'time()';
                break;
            case 'foreach':
                array_shift($indexes);
                $_var = $indexes[0];
                $_propname = $indexes[1];
                switch ($_propname) {
                    case 'index':
                        array_shift($indexes);
                        $compiled_ref = "(\$this->_foreach['$_var']['iteration'] - 1)";
                        break;
                    case 'first':
                        array_shift($indexes);
                        $compiled_ref = "(\$this->_foreach['$_var']['iteration'] <= 1)";
                        break;
                    case 'last':
                        array_shift($indexes);
                        $compiled_ref = "(\$this->_foreach['$_var']['iteration'] == \$this->_foreach['$_var']['total'])";
                        break;
                    case 'show':
                        array_shift($indexes);
                        $compiled_ref = "(\$this->_foreach['$_var']['total'] > 0)";
                        break;
                    default:
                        $compiled_ref = "\$this->_foreach['$_var']";
                        break;
                }
                break;
            case 'get':
                $compiled_ref = '$_GET';
                break;
            case 'post':
                $compiled_ref = '$_POST';
                break;
            case 'cookies':
                $compiled_ref = '$_COOKIE';
                break;
            case 'env':
                $compiled_ref = '$_ENV';
                break;
            case 'server':
                $compiled_ref = '$_SERVER';
                break;
            case 'request':
                $compiled_ref = '$_REQUEST';
                break;
            case 'session':
                $compiled_ref = '$_SESSION';
                break;
            default:
                // $this->_syntax_error('$smarty.' . $_ref . ' is an unknown reference', E_USER_ERROR, __FILE__, __LINE__);
                break;
        }
        array_shift($indexes);
        return $compiled_ref;
    }

    /**
     * 页面上调用的js文件
     *
     * @access  public
     * @param   string      $files
     * @return  void
     */
    public function smarty_insert_scripts($args)
    {
        static $scripts = array();
        $arr = explode(',', str_replace(' ', '', $args['files']));
        $str = '';
        foreach ($arr as $val) {
            if (in_array($val, $scripts) == false) {
                $scripts[] = $val;
                if ($val{0} == '.') {
                    $val = explode('/', $val);
                    ;
                    $val = $val[1];
                    $str .= '<script type="text/javascript" src="../clientscript/' .
                            $val . '"></script>';
                } else {
                    $str .= '<script type="text/javascript" src="clientscript/' .
                            $val . '"></script>';
                }
            }
        }
        return $str;
    }

    /**
     * 模版文件编译前预处理
     *
     * @access  public
     * @param   string      $source
     * @return  void
     */
    public function smarty_prefilter_preCompile($source)
    {
        global $skyuc;
        $file_type = strtolower(strrchr($this->_current_file, '.'));
        $tmp_dir = 'templates/' . $skyuc->options['themes'] . '/'; // 模板所在路径
        /**
         * 处理模板文件
         */
        if ($file_type == '.dwt') {
            /* 将模板中所有library替换为链接 */
            $pattern = '/<!--\s#BeginLibraryItem\s\"\/(.*?)\"\s-->.*?<!--\s#EndLibraryItem\s-->/se';
            $replacement = "'{include file='.strtolower('\\1'). '}'";
            $source = preg_replace($pattern, $replacement, $source);
            /* 检查有无动态库文件，如果有为其赋值 */
            $dyna_libs = get_dyna_libs($skyuc->options['themes'],
                                       $this->_current_file);
            if ($dyna_libs) {
                foreach ($dyna_libs as $region => $libs) {
                    $pattern = '/<!--\\s*TemplateBeginEditable\\sname="' .
                               $region .
                               '"\\s*-->(.*?)<!--\\s*TemplateEndEditable\\s*-->/s';
                    if (preg_match($pattern, $source, $reg_match)) {
                        $reg_content = $reg_match[1];
                        /* 生成匹配字串 */
                        $keys = array_keys($libs);
                        $lib_pattern = '';
                        foreach ($keys as $lib) {
                            $lib_pattern .= '|' .
                                            str_replace('/', '\/', substr($lib, 1));
                        }
                        $lib_pattern = '/{include\sfile=(' .
                                       substr($lib_pattern, 1) . ')}/';
                        /* 修改$reg_content中的内容 */
                        $GLOBALS['libs'] = $libs;
                        $reg_content = preg_replace_callback($lib_pattern,
                                                             'dyna_libs_replace', $reg_content);
                        /* 用修改过的内容替换原来当前区域中内容 */
                        $source = preg_replace($pattern, $reg_content, $source);
                    }
                }
            }
            /* 在头部加入版本信息 */
            $source = preg_replace('/<head>/i',
                                   "<head>\r\n<meta name=\"Generator\" content=\"" . APPNAME . ' ' .
                                   VERSION . "\" />", $source);
            $file = pack("H*", '2f646174612f736b7975635f6b65792e706870');
            if (!is_file(DIR . $file)) {
                /* 添加版权信息 */
                $source = preg_replace('/<title>([^<]*)<\/title>/i',
                                       '<title>\1 - Powered by ' . APPNAME . '</title>', $source);
            }
            /* 修正css路径 */
            $source = preg_replace(
                '/(<link\shref=["|\'])(?:\.\/|\.\.\/)?(css\/)?([a-z0-9A-Z_]+\.css["|\']\srel=["|\']stylesheet["|\']\stype=["|\']text\/css["|\'])/i',
                '\1' . $tmp_dir . '\2\3', $source);
            /* 修正js目录下js的路径 */
            $source = preg_replace(
                '/(<script\s(?:type|language)=["|\']text\/javascript["|\']\ssrc=["|\'])(?:\.\/|\.\.\/)?(js\/[a-z0-9A-Z_\-\.]+\.(?:js|vbs)["|\']><\/script>)/',
                '\1' . $tmp_dir . '\2', $source);
        } /**
         * 处理库文件
         */
        elseif ($file_type == '.lbi') {
            /* 去除meta */
            $source = preg_replace(
                '/<meta\shttp-equiv=["|\']Content-Type["|\']\scontent=["|\']text\/html;\scharset=(?:.*?)["|\']>\r?\n?/i',
                '', $source);
        }
        /* 替换文件编码头部 */
        if (strpos($source, "\xEF\xBB\xBF") !== FALSE) {
            $source = str_replace("\xEF\xBB\xBF", '', $source);
        }
        $pattern = array('/<!--[^>|\n]*?({.+?})[^<|{|\n]*?-->/', // 替换smarty注释
                         '/<!--[^<|>|{|\n]*?-->/', // 替换不换行的html注释
                         '/(href=["|\'])\.\.\/(.*?)(["|\'])/i', // 替换相对链接
                         '/((?:background|src)\s*=\s*["|\'])(?:\.\/|\.\.\/)?(images\/.*?["|\'])/is', // 在images前加上 $tmp_dir
                         '/((?:background|background-image):\s*?url\()(?:\.\/|\.\.\/)?(images\/)/is', // 在images前加上 $tmp_dir
                         '/([\'|"])\.\.\//is'); // 以../开头的路径全部修正为空
        $replace = array('\1', '', '\1\2\3', '\1' . $tmp_dir . '\2',
                         '\1' . $tmp_dir . '\2', '\1');
        return preg_replace($pattern, $replace, $source);
    }

    public function insert_mod($name) // 处理动态内容
    {
        list ($fun, $para) = explode('|', $name);
        $para = unserialize($para);
        $fun = 'insert_' . $fun;
        return $fun($para);
    }

    public function str_trim($str)
    {
        /* 处理'a=b c=d k = f '类字符串，返回数组 */
        while (strpos($str, '= ') != 0) {
            $str = str_replace('= ', '=', $str);
        }
        while (strpos($str, ' =') != 0) {
            $str = str_replace(' =', '=', $str);
        }
        return explode(' ', trim($str));
    }

    public function _eval($content)
    {
        ob_start();
        eval('?' . '>' . trim($content));
        $content = ob_get_contents();
        ob_end_clean();
        return $content;
    }

    public function _require($filename)
    {
        ob_start();
        include $filename;
        $content = ob_get_contents();
        ob_end_clean();
        return $content;
    }

    /**
     * 下拉菜单,模拟smarty的html_options函数
     *
     * @access  public
     * @param   array      $arr
     * @return  void
     */
    public function html_options($arr)
    {
        $selected = $arr['selected'];
        if ($arr['options']) {
            $options = (array)$arr['options'];
        } elseif ($arr['output']) {
            if ($arr['values']) {
                foreach ($arr['output'] as $key => $val) {
                    $options["{$arr[values][$key]}"] = $val;
                }
            } else {
                $options = array_values((array)$arr['output']);
            }
        }
        if ($options) {
            foreach ($options as $key => $val) {
                $out .= $key == $selected
                        ? "<option value=\"$key\" selected>$val</option>"
                        : "<option value=\"$key\">$val</option>";
            }
        }
        return $out;
    }

    /**
     * 下拉菜单日期,模拟smarty的html_select_date函数
     *
     * @access  public
     * @param   array      $arr
     * @return  void
     */
    public function html_select_date($arr)
    {
        $pre = $arr['prefix'];
        if (isset($arr['time'])) {
            if (intval($arr['time']) > 10000) {
                $arr['time'] = skyuc_date('Y-m-d', $arr['time']);
            }
            $t = explode('-', $arr['time']);
            $year = strval($t[0]);
            $month = strval($t[1]);
            $day = strval($t[2]);
        }
        $now = skyuc_date('Y', $this->_nowtime);
        if (isset($arr['start_year'])) {
            if (strlen(abs($arr['start_year'])) == strlen($arr['start_year'])) {
                $startyear = $arr['start_year'];
            } else {
                $startyear = $arr['start_year'] + $now;
            }
        } else {
            $startyear = $now - 1;
        }
        if (isset($arr['end_year'])) {
            if (strlen(abs($arr['end_year'])) == strlen($arr['end_year'])) {
                $endyear = $arr['end_year'];
            } else {
                $endyear = $arr['end_year'] + $now;
            }
        } else {
            $endyear = $now;
        }
        $out = "<select name=\"{$pre}Year\">";
        for ($i = $startyear; $i <= $endyear; $i++) {
            $out .= $i == $year ? "<option value=\"$i\" selected>$i</option>"
                    : "<option value=\"$i\">$i</option>";
        }
        if ($arr['display_months'] != 'false') {
            $out .= "</select>&nbsp;<select name=\"{$pre}Month\">";
            for ($i = 1; $i <= 12; $i++) {
                $out .= ($i == $month) ? "<option value=\"$i\" selected>" .
                                         str_pad($i, 2, '0', STR_PAD_LEFT) . "</option>"
                        : "<option value=\"$i\">" .
                          str_pad($i, 2, '0', STR_PAD_LEFT) . "</option>";
            }
        }
        if ($arr['display_days'] != 'false') {
            $out .= "</select>&nbsp;<select name=\"{$pre}Day\">";
            for ($i = 1; $i <= 31; $i++) {
                $out .= ($i == $day) ? "<option value=\"$i\" selected>" .
                                       str_pad($i, 2, '0', STR_PAD_LEFT) . "</option>"
                        : "<option value=\"$i\">" .
                          str_pad($i, 2, '0', STR_PAD_LEFT) . "</option>";
            }
        }
        return $out . '</select>';
    }

    /**
     * 单选框,模拟smarty的html_radios函数
     *
     * @access  public
     * @param   array      $arr
     * @return  void
     */
    public function html_radios($arr)
    {
        $name = $arr['name'];
        $checked = $arr['checked'];
        $options = $arr['options'];
        $out = '';
        foreach ($options as $key => $val) {
            $out .= $key == $checked
                    ? "<input type=\"radio\" name=\"$name\" value=\"$key\" checked>&nbsp;{$val}&nbsp;"
                    : "<input type=\"radio\" name=\"$name\" value=\"$key\">&nbsp;{$val}&nbsp;";
        }
        return $out;
    }

    /**
     * 多选框,模拟smarty的html_checkboxes函数
     *
     * @access  public
     * @param   array      $arr
     * @return  void
     */
    public function html_checkboxes($arr)
    {
        $name = $arr['name'];
        $checked = empty($arr['checked']) ? array() : $arr['checked'];
        $options = $arr['options'];
        $separator = isset($arr['separator']) ? $arr['separator'] : '&nbsp;';
        if (!is_array($checked)) {
            $checked = explode(',', $checked);
        }
        $out = '';
        foreach ($options as $key => $val) {
            $out .= in_array($key, $checked)
                    ? "<label><input type=\"checkbox\" name=\"$name\" value=\"$key\" checked>&nbsp;{$val}</label>$separator"
                    : "<label><input type=\"checkbox\" name=\"$name\" value=\"$key\">&nbsp;{$val}</label>$separator";
        }
        return $out;
    }

    /**
     * 下拉菜单时间,模拟smarty的html_select_time函数
     *
     * @access  public
     * @param   array      $arr
     * @return  void
     */
    public function html_select_time($arr)
    {
        $pre = $arr['prefix'];
        if (isset($arr['time'])) {
            $arr['time'] = skyuc_date('H-i-s', $arr['time']);
            $t = explode('-', $arr['time']);
            $hour = strval($t[0]);
            $minute = strval($t[1]);
            $second = strval($t[2]);
        }
        $out = '';
        if (!isset($arr['display_hours'])) {
            $out .= "<select name=\"{$pre}Hour\">";
            for ($i = 0; $i <= 23; $i++) {
                $out .= $i == $hour ? "<option value=\"$i\" selected>" .
                                      str_pad($i, 2, '0', STR_PAD_LEFT) . "</option>"
                        : "<option value=\"$i\">" .
                          str_pad($i, 2, '0', STR_PAD_LEFT) . "</option>";
            }
            $out .= "</select>&nbsp;";
        }
        if (!isset($arr['display_minutes'])) {
            $out .= "<select name=\"{$pre}Minute\">";
            for ($i = 0; $i <= 59; $i++) {
                $out .= $i == $minute ? "<option value=\"$i\" selected>" .
                                        str_pad($i, 2, '0', STR_PAD_LEFT) . "</option>"
                        : "<option value=\"$i\">" .
                          str_pad($i, 2, '0', STR_PAD_LEFT) . "</option>";
            }
            $out .= "</select>&nbsp;";
        }
        if (!isset($arr['display_seconds'])) {
            $out .= "<select name=\"{$pre}Second\">";
            for ($i = 0; $i <= 59; $i++) {
                $out .= $i == $second ? "<option value=\"$i\" selected>" .
                                        str_pad($i, 2, '0', STR_PAD_LEFT) . "</option>"
                        : "<option value=\"$i\">$i</option>";
            }
            $out .= "</select>&nbsp;";
        }
        return $out;
    }

    /**
     * 模拟smarty的cycle函数
     *
     * @access  public
     * @param   array      $arr
     * @return  void
     */
    public function cycle($arr)
    {
        static $k, $old;
        $value = explode(',', $arr['values']);
        if ($old != $value) {
            $old = $value;
            $k = 0;
        } else {
            $k++;
            if (!isset($old[$k])) {
                $k = 0;
            }
        }
        echo $old[$k];
    }

    /**
     * 创建数组,用于模拟smarty的html_*函数
     *
     * @access  public
     * @param   array      $arr
     * @return  void
     */
    public function make_array($arr)
    {
        $out = '';
        foreach ($arr as $key => $val) {
            if ($val{0} == '$') {
                $out .= $out ? ",'$key'=>$val" : "array('$key'=>$val";
            } else {
                $out .= $out ? ",'$key'=>'$val'" : "array('$key'=>'$val'";
            }
        }
        return $out . ')';
    }

    /**
     * 创建分页的列表
     *
     * @access  public
     * @param   integer $count
     * @return  string
     */
    public function smarty_create_pages($params)
    {
        extract($params);
        if (empty($page)) {
            $page = 1;
        }
        if (!empty($count)) {
            $str = "<option value='1'>1</option>";
            $min = min($count - 1, $page + 3);
            for ($i = $page - 3; $i <= $min; $i++) {
                if ($i < 2) {
                    continue;
                }
                $str .= "<option value='$i'";
                $str .= $page == $i ? " selected='true'" : '';
                $str .= ">$i</option>";
            }
            if ($count > 1) {
                $str .= "<option value='$count'";
                $str .= $page == $count ? " selected='true'" : '';
                $str .= ">$count</option>";
            }
        } else {
            $str = '';
        }
        return $str;
    }
}

?>