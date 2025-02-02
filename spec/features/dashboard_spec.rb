# frozen_string_literal: true

require 'rails_helper'

feature 'Punches Dashboard', js: true do
  context 'When user has overtime allowed' do
    let!(:authed_user_with_overtime) { create_logged_in_user(allow_overtime: true) }
    let!(:active_project) { create(:project, :active, company_id: authed_user_with_overtime.company_id) }

    scenario 'Calendar navigation' do
      visit '/dashboard/2014/12'

      expect(page).to have_content('Nov / Dec 2014')
      find('a', text: '❯').click
      expect(page).to have_content('Dec 2014 / Jan 2015')
      find('a', text: '❮').click
      expect(page).to have_content('Nov / Dec 2014')
    end

    scenario 'Insert and delete punches' do
      visit '/dashboard/2013/10'

      find('td.inner', text: '10').click
      find('td.inner', text: '11').click
      find('span.select2').click
      find('li.select2-results__option').click
      click_on 'Salvar'
      expect(page).to have_content("Selecionado (0)")

      visit '/dashboard/2013/10'
      find('td.inner', text: '15').click
      find('button', text: 'Apagar').click
      expect(page).to have_content("Selecionado (0)")
    end

    scenario 'Insert punches on holiday' do
      visit 'dashboard/2013/11'

      find('td.inner', text: '02').click
      find('td.inner', text: '15').click
      find('span.select2').click
      find('li.select2-results__option').click
      expect(page).to have_content("Selecionado (2)")
      click_on 'Salvar'
      expect(page).to have_content("Selecionado (0)")
    end

    scenario 'Multiple selection through sheets' do
      visit '/dashboard/2018/02'

      find('td.inner', text: '19').click
      find('td.inner', text: '20').click
      expect(page).to have_content('Selecionado (2)')
      expect(page).to have_content('Selecionado (2)')


      within 'tbody > tr:nth-child(1)' do
        expect(page).to have_css("td.selected", text: "19") & have_css("td.selected", text: "20")
      end

      find('td.inner', text: '21').click
      find('span.select2').click
      find('li.select2-results__option').click
      expect(page).to have_content('Selecionado (3)')
      click_on 'Salvar'
      expect(page).to have_content('Horas: 24')
    end

    scenario 'When no project has been selected' do
      visit '/dashboard/2018/02'
      find('td.inner', text: '21').click
      expect(page).to have_button('Salvar', disabled: true)
    end
  end

  context 'When user do not have overtime allowed' do
    let!(:authed_user_without_overtime) { create_logged_in_user }
    let!(:active_project) { create(:project, :active, company_id: authed_user_without_overtime.company_id) }

    scenario 'Insert punches on holiday' do
      visit 'dashboard/2013/11'

      find('td.inner', text: '02').click
      find('td.inner', text: '03').click
      find('span.select2').click
      find('li.select2-results__option').click
      expect(page).to have_content("Selecionado (1)")

      accept_alert do
        click_on 'Salvar'
        expect(page).to have_content("Selecionado (0)")
      end
    end
  end

  context 'When user try to save a punch with delta zero' do
    let!(:authed_user_without_overtime) { create_logged_in_user }
    let!(:active_project) { create(:project, :active, company_id: authed_user_without_overtime.company_id) }

    scenario 'Renders save button disabled' do
      visit '/dashboard/2022/06'

      find('td.inner', text: '06').click
      find('span.select2').click
      find('li.select2-results__option').click

      hour_inputs = all('.form-control')

      morning_start_input = hour_inputs[0]
      morning_end_input = hour_inputs[1]

      lunch_start_input = hour_inputs[2]
      lunch_end_input = hour_inputs[3]

      morning_start_input.set('09:00')
      morning_end_input.set('12:00')   

      lunch_start_input.set('09:00')
      lunch_end_input.set('12:00')      

      save_button = find('.w-100')
      
      expect(save_button.disabled?).to eq(true)
    end
  end
end
