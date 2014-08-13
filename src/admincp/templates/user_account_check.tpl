{include file="pageheader.tpl"}
<div class="main-div">
<form method="post" action="user_account.php" name="theForm" onsubmit="return validate();">
<table border="0" width="100%">
  <tr>
    <td colspan="2"><strong>{$lang.surplus_info}：</strong><hr /></td>
  </tr>
  <tr>
    <td colspan="2">
    <strong>{$lang.user_id}：</strong>{$user_name} &nbsp;&nbsp;<strong>{$lang.surplus_amount}：</strong>{$surplus.amount} &nbsp;&nbsp;<strong>{$lang.add_date}：</strong>{$surplus.add_time}
    &nbsp;&nbsp;<strong>{$lang.process_type}：</strong>{$process_type}
    {if $surplus.pay_method}&nbsp;&nbsp;<strong>{$lang.pay_method}：</strong>{$surplus.payment}{/if}
    </td>
  </tr>
  <tr>
    <td colspan="2"><strong>{$lang.surplus_desc}：</strong>{$surplus.user_note}<hr /></td>
  </tr>
  <tr>
    <th width="15%" valign="middle" align="right">{$lang.surplus_notic}：</th>
    <td width="85%">
      <textarea class="textCtrl" name="admin_note" cols="55" rows="5">{$surplus.admin_note}</textarea>
    </td>
  </tr>
  <tr>
    <th width="15%" valign="middle" align="right">{$lang.status}：</th>
    <td>
      <input type="radio" name="is_paid" value="0" checked="true" />{$lang.unconfirm}
      <input type="radio" name="is_paid" value="1" />{$lang.confirm}
    </td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>
      <input type="hidden" name="act" value="action" />
      <input type="hidden" name="id" value="{$id}" />
      <input name="submit" type="submit" class="button primary submitButton"  value="{$lang.button_submit}"  />
      <input type="reset" class="button submitButton"  value="{$lang.button_reset}"  />
    </td>
  </tr>
</table>
</form>
</div>
{insert_scripts files="skyuc_validator.js"}

<script language="JavaScript">
<!--
document.forms['theForm'].elements['admin_note'].focus();

/**
 * 检查表单输入的数据
 */
function validate()
{
    validator = new Validator("theForm");
    validator.required("admin_note",  deposit_notic_empty);
    return validator.passed();
}

//-->
</script>

{include file="pagefooter.tpl"}
