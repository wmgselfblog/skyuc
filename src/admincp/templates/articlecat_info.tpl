{include file="pageheader.tpl"}
<div class="main-div">
<form method="post" action="articlecat.php" name="theForm"  onsubmit="return validate()">
<table cellspacing="1" cellpadding="3" width="100%">
  <tr>
    <td class="label">{$lang.cat_name}</td>
    <td><input type="text"  name="cat_name" maxlength="60" size = "30" value="{$cat.cat_name|escape}" />{$lang.require_field}</td>
  </tr>
  <tr>
    <td class="label">{$lang.parent_cat}</td>
    <td>
      <select class="textCtrl"  name="parent_id" onchange="catChanged()" {if $disabled }disabled="disabled"{/if} >
        <option value="0">{$lang.cat_top}</option>
        {$cat_select}
      </select>
    </td>
  </tr>
  <tr>
    <td class="label">{$lang.sort_order}:</td>
    <td>
      <input type="text"  name='sort_order' {if $cat.sort_order}value='{$cat.sort_order}'{else} value="0"{/if} size="15" />
    </td>
  </tr>
    <tr>
    <td class="label">{$lang.show_in_nav}:</td>
    <td>
      <input type="radio" name="show_in_nav" value="1" {if $cat.show_in_nav neq 0} checked="true"{/if}/> {$lang.yes}
      <input type="radio" name="show_in_nav" value="0" {if $cat.show_in_nav eq 0} checked="true"{/if} /> {$lang.no}
    </td>
  </tr>
  <tr>
    <td class="label"><a href="javascript:showNotice('notice_keywords');" title="{$lang.form_notice}">
        <img src="images/notice.gif" width="16" height="16" border="0" alt="{$lang.form_notice}"></a>{$lang.cat_keywords}</td>
    <td><input type="text"  name="keywords" maxlength="60" size="50" value="{$cat.keywords|escape}" />
    <br /><span class="notice-span" id="notice_keywords">{$lang.notice_keywords}</span>
    </td>
  </tr>
  <tr>
    <td class="label">{$lang.cat_desc}</td>
    <td><textarea class="textCtrl"  name="cat_desc" cols="60" rows="4">{$cat.cat_desc|escape}</textarea></td>
  </tr>
  <tr>
    <td colspan="2" align="center"><br />
      <input type="submit" class="button primary submitButton"  value="{$lang.button_submit}" />
      <input type="reset" class="button submitButton"   value="{$lang.button_reset}" />
      <input type="hidden" name="act" value="{$form_action}" />
      <input type="hidden" name="id" value="{$cat.cat_id}" />
      <input type="hidden" name="old_catname" value="{$cat.cat_name}" />
    </td>
  </tr>
</table>
</form>
</div>
{insert_scripts files="skyuc_validator.js"}
{literal}
<script language="JavaScript">
<!--
/**
 * 检查表单输入的数据
 */
function validate()
{
    validator = new Validator("theForm");
    validator.required("cat_name",  no_catname);
    return validator.passed();
}

/**
 * 选取上级分类时判断选定的分类是不是底层分类
 */
function catChanged()
{
  var obj = document.forms['theForm'].elements['parent_id'];

  cat_type = obj.options[obj.selectedIndex].getAttribute('cat_type');
  if (cat_type == undefined)
  {
    cat_type = 1;
  }

  if ((obj.selectedIndex > 0) && (cat_type == 2 || cat_type == 3 || cat_type == 5))
  {
    alert(sys_hold);
    obj.selectedIndex = 0;
    return false;
  }

  return true;
}

//-->
</script>
{/literal}
{include file="pagefooter.tpl"}
