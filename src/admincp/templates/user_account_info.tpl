{include file="pageheader.tpl"}
{insert_scripts files="validator.js"}
<div class="main-div">
  <form action="user_account.php" method="post" name="theForm" onsubmit="return validate()">
    <table width="100%">
      <tr>
        <td class="label">{$lang.user_id}：</td>
        <td>
          <input type="text"  name="user_id" value="{$user_name}" size="20"
          {if $user_surplus.process_type eq 2 || $user_surplus.process_type eq 3 || $action eq "edit"} readonly="true" {/if}/>
        </td>
      </tr>
      <tr>
        <td class="label">{$lang.surplus_amount}：</td>
        <td>
          <input type="text"  name="amount" value="{$user_surplus.amount}" size="20"
          {if $user_surplus.process_type eq 2 || $user_surplus.process_type eq 3 || $action eq "edit"} readonly="true" {/if}/>
        </td>
      </tr>
      <tr>
        <td class="label">{$lang.pay_mothed}：</td>
        <td>
          <select class="textCtrl"  name="payment" {if $user_surplus.process_type eq 2 || $user_surplus.process_type eq 3}disabled="true" {/if}>
          <option value="">{$lang.please_select}</option>
          {html_options options=$payment_list selected=$user_surplus.payment}
          </select>
        </td>
        </td>
      </tr>
      <tr>
        <td class="label">{$lang.process_type}：</td>
        <td>
          <input type="radio" name="process_type" value="0"
          {if $user_surplus.process_type eq 0} checked="true" {/if} {if $user_surplus.process_type eq 2 || $user_surplus.process_type eq 3 || $action eq "edit"}disabled="true" {/if} />{$lang.surplus_type_0}
          <input type="radio" name="process_type" value="1"
          {if $user_surplus.process_type eq 1} checked="true" {/if} {if $user_surplus.process_type eq 2 || $user_surplus.process_type eq 3|| $action eq "edit"}disabled="true" {/if} />{$lang.surplus_type_1}
          {if $action eq "edit" && ($user_surplus.process_type eq 2 || $user_surplus.process_type eq 3)}
          <input type="radio" name="process_type" value="2"
          {if $user_surplus.process_type eq 2|| $action eq "edit"} checked="true"{/if}{if $user_surplus.process_type eq 2 || $user_surplus.process_type eq 3} disabled="true"{/if} />{$lang.surplus_type_2}
          <input type="radio" name="process_type" value="3"
          {if $user_surplus.process_type eq 3|| $action eq "edit"} checked="true"{/if}{if $user_surplus.process_type eq 2 || $user_surplus.process_type eq 3} disabled="true"{/if} />{$lang.surplus_type_3}
          {/if}
        </td>
      </tr>
      <tr>
        <td class="label">{$lang.surplus_notic}：</td>
        <td>
          <textarea class="textCtrl" name="admin_note" cols="55" rows="3"{if $user_surplus.process_type eq 2 || $user_surplus.process_type eq 3} readonly="true" {/if}>{$user_surplus.admin_note}</textarea>
        </td>
      </tr>
      <tr>
        <td class="label">{$lang.surplus_desc}：</td>
        <td>
          <textarea class="textCtrl" name="user_note" cols="55" rows="3"{if $user_surplus.process_type eq 2 || $user_surplus.process_type eq 3} readonly="true" {/if}>{$user_surplus.user_note}</textarea>
        </td>
      </tr>
      <tr>
        <td class="label">{$lang.status}：</td>
        <td>
          <input type="radio" name="is_paid" value="0"
          {if $user_surplus.is_paid eq 0} checked="true"{/if} {if $user_surplus.process_type eq 2 || $user_surplus.process_type eq 3 ||$action eq "edit"} disabled="true"{/if}/>{$lang.unconfirm}
          <input type="radio" name="is_paid" value="1"
          {if $user_surplus.is_paid eq 1} checked="true" {/if} {if $user_surplus.process_type eq 2 || $user_surplus.process_type eq 3 ||$action eq "edit"} disabled="true"{/if}/>{$lang.confirm}
          <input type="radio" name="is_paid" value="2"
          {if $user_surplus.is_paid eq 2} checked="true" {/if} {if $user_surplus.process_type eq 2 || $user_surplus.process_type eq 3 ||$action eq "edit"} disabled="true"{/if}/>{$lang.cancel}
        </td>
      </tr>
      <tr>
        <td class="label">&nbsp;</td>
        <td>
          <input type="hidden" name="id" value="{$user_surplus.id}" />
          <input type="hidden" name="act" value="{$form_act}" />
          {if $user_surplus.process_type eq 0 || $user_surplus.process_type eq 1}
          <input type="submit" class="button primary submitButton" value="{$lang.button_submit}"  />
          <input type="reset" class="button submitButton"  value="{$lang.button_reset}"  />
          {/if}
        </td>
      </tr>
    </table>
  </form>
</div>

<script language="JavaScript">
<!--

/**
 * 检查表单输入的数据
 */
function validate()
{
    validator = new Validator("theForm");

    validator.required("user_id",   user_id_empty);
    validator.required("amount",    deposit_amount_empty);
    validator.isNumber("amount",    deposit_amount_error, true);

    var deposit_amount = document['theForm'].elements['amount'].value;
    if (deposit_amount.length > 0)
    {
        if (deposit_amount == 0 || deposit_amount < 0)
        {
            alert(deposit_amount_error);
            return false;
        }
    }

    return validator.passed();
}

//-->

</script>
{include file="pagefooter.tpl"}
