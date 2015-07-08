React = require 'react'
PromiseRenderer = require '../../components/promise-renderer'
ChangeListener = require '../../components/change-listener'
handleInputChange = require '../../lib/handle-input-change'

module.exports = React.createClass
  displayName: 'EmailSettingsPage'

  getDefaultProps: ->
    user: null

  render: ->
    <div className="content-container">
      <p><strong>Project email preferences</strong></p>
      <table>
        <thead>
          <tr>
            <th><i className="fa fa-envelope-o fa-fw"></i></th>
            <th>Project</th>
          </tr>
        </thead>
        <PromiseRenderer promise={@props.user.get 'project_preferences'} pending={=> <tbody></tbody>} then={(projectPreferences) =>
          <tbody>
            {for projectPreference in projectPreferences then do (projectPreference) =>
              <PromiseRenderer key={projectPreference.id} promise={projectPreference.get 'project'} then={(project) =>
                <ChangeListener target={projectPreference} handler={=>
                  <tr>
                    <td><input type="checkbox" name="email_communication" checked={projectPreference.email_communication} onChange={@handleProjectEmailChange.bind this, projectPreference} /></td>
                    <td>{project.display_name}</td>
                  </tr>
                } />
              } />}
          </tbody>
        } />
      </table>
    </div>

  handleProjectEmailChange: (projectPreference, args...) ->
    handleInputChange.apply projectPreference, args
    projectPreference.save()