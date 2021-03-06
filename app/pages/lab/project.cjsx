React = require 'react'
{History, Link, IndexLink} = require 'react-router'
PromiseRenderer = require '../../components/promise-renderer'
LoadingIndicator = require '../../components/loading-indicator'
TitleMixin = require '../../lib/title-mixin'
HandlePropChanges = require '../../lib/handle-prop-changes'
apiClient = require 'panoptes-client/lib/api-client'
counterpart = require 'counterpart'
ChangeListener = require '../../components/change-listener'
Router = require 'react-router'

DEFAULT_WORKFLOW_NAME = 'Untitled workflow'
DEFAULT_SUBJECT_SET_NAME = 'Untitled subject set'
DELETE_CONFIRMATION_PHRASE = 'I AM DELETING THIS PROJECT'

EditProjectPage = React.createClass
  displayName: 'EditProjectPage'

  mixins: [TitleMixin, History]

  title: ->
    @props.project.display_name

  getDefaultProps: ->
    project: id: '2'

  getInitialState: ->
    workflowCreationError: null
    workflowCreationInProgress: false
    subjectSetCreationError: null
    subjectSetCreationInProgress: false
    deletionError: null
    deletionInProgress: false

  labPath: (postFix = '') ->
    "/lab/#{@props.project.id}#{postFix}"

  render: ->
    linkParams =
      projectID: @props.project.id

    <div className="columns-container content-container">
      <div>
        <ul className="nav-list">
          <li><div className="nav-list-header">Project #{@props.project.id}</div></li>

          <li><IndexLink to={@labPath()} activeClassName='active' className="nav-list-item" title="Input the basic information about your project, and set up its home page.">
            Project details
          </IndexLink></li>
          <li><Link to={@labPath('/research')} activeClassName='active' className="nav-list-item" title="Explain your research to your audience here in as much detail as you’d like.">
            Research
          </Link></li>
          <li><Link to={@labPath('/results')} activeClassName='active' className="nav-list-item" title="Once your project has hit its stride, share the results of your project with your volunteers here.">
            Results
          </Link></li>
          <li><Link to={@labPath('/faq')} activeClassName='active' className="nav-list-item" title="Add details here about your research, how to classify, and what you plan to do with the classifications.">
            FAQ
          </Link></li>
          <li><Link to={@labPath('/education')} activeClassName='active' className="nav-list-item" title="If you are a researcher open to collaborating with educators, or if your project is primarily for educational purposes, you can describe that here.">
            Education
          </Link></li>
          <li><Link to={@labPath('/collaborators')} activeClassName='active' className="nav-list-item" title="Add people to your team and specify what their roles are so that they have the right access to the tools they need (including access to the project while it’s private).">
            Collaborators
          </Link></li>
          {if 'field guide' in (@props.project.experimental_tools ? [])
            <li><Link to={@labPath('/guide')} activeClassName='active' className="nav-list-item" title="Create a persistent guide that can be viewed within your project">
              Field guide
            </Link></li>}
          {if 'tutorial' in (@props.project.experimental_tools ? [])
            <li><Link to={@labPath('/tutorial')} activeClassName='active' className="nav-list-item" title="Create a pop-up tutorial for your project’s classification interface">
              Tutorial
            </Link></li>}
          {if 'mini-course' in (@props.project.experimental_tools ? [])
            <li><Link to={@labPath('/mini-course')} activeClassName='active' className="nav-list-item" title="Create a pop-up mini-course for your project’s classification interface">
              Mini-course
            </Link></li>}
          <li><Link to={@labPath('/media')} activeClassName='active' className="nav-list-item" title="Add any images you’d like to use in this project’s introduction, science case, results, FAQ, or education content pages.">
            Media
          </Link></li>
          <li><Link to={@labPath('/visibility')} activeClassName='active' className="nav-list-item" title="Decide whether your project is public and whether it's ready to go live.">
            Visibility
          </Link></li>
          <li><Link to={@labPath('/talk')} activeClassName='active' className="nav-list-item" title="Setup project specific discussion boards">
            Talk
          </Link></li>
          <li><Link to={@labPath('/data-exports')} activeClassName='active' className="nav-list-item" title="Get your project's data exports">
            Data Exports
          </Link></li>

          <li>
            <br />
            <div className="nav-list-header">Workflows</div>
            <PromiseRenderer promise={@props.project.get 'workflows'}>{(workflows) =>
              <ul className="nav-list">
                {renderWorkflowListItem = (workflow) ->
                  <li key={workflow.id}>
                    <Link to={@labPath("/workflow/#{workflow.id}")} activeClassName="active" className="nav-list-item" title="A workflow is the sequence of tasks that you’re asking volunteers to perform.">{workflow.display_name}</Link>
                  </li>}

                {for workflow in workflows
                  <ChangeListener key={workflow.id} target={workflow} eventName="save" handler={renderWorkflowListItem.bind this, workflow} />}

                <li className="nav-list-item">
                  <button type="button" onClick={@createNewWorkflow} disabled={@props.project.live or @state.workflowCreationInProgress} title="A workflow is the sequence of tasks that you’re asking volunteers to perform.">
                    New workflow{' '}
                    <LoadingIndicator off={not @state.workflowCreationInProgress} />
                  </button>{' '}
                  {if @state.workflowCreationError?
                    <div className="form-help error">{@state.workflowCreationError.message}</div>}
                </li>
              </ul>
            }</PromiseRenderer>
          </li>

          <li>
            <br />
            <div className="nav-list-header">Subject sets</div>
            <PromiseRenderer promise={@props.project.get 'subject_sets'}>{(subjectSets) =>
              <ul className="nav-list">
                {renderSubjectSetListItem = (subjectSet) ->
                  subjectSetListLabel = subjectSet.display_name || <i>{'Untitled subject set'}</i>
                  <li key={subjectSet.id}>
                    <Link to={@labPath("/subject-set/#{subjectSet.id}")} activeClassName="active" className="nav-list-item" title="A subject is an image (or group of images) to be analyzed.">{subjectSetListLabel}</Link>
                  </li>}

                {for subjectSet in subjectSets
                  <ChangeListener key={subjectSet.id} target={subjectSet} eventName="save" handler={renderSubjectSetListItem.bind this, subjectSet} />}

                <li className="nav-list-item">
                  <button type="button" onClick={@createNewSubjectSet} disabled={@state.subjectSetCreationInProgress} title="A subject is an image (or group of images) to be analyzed.">
                    New subject set{' '}
                    <LoadingIndicator off={not @state.subjectSetCreationInProgress} />
                  </button>{' '}
                  {if @state.subjectSetCreationError?
                    <div className="form-help error">{@state.subjectSetCreationError.message}</div>}
                </li>
              </ul>
            }</PromiseRenderer>
          </li>

          <li>
            <br />
            <div className="nav-list-header">Need some help?</div>
            <ul className="nav-list">
              <li>
                <Link className="nav-list-item" to="/lab-how-to">Read a tutorial</Link>
              </li>
              <li>
                <Link to="/talk/18" className="nav-list-item">Ask for help on talk</Link>
              </li>
            </ul>
          </li>
        </ul>

        <br />
        <div className="nav-list-header">Other actions</div>
        <small><button type="button" className="minor-button" disabled={@state.deletionInProgress} onClick={@deleteProject}>Delete this project <LoadingIndicator off={not @state.deletionInProgress} /></button></small>{' '}
        {if @state.deletionError?
          <div className="form-help error">{@state.deletionError.message}</div>}
      </div>

      <hr />

      <div className="column">
        <ChangeListener target={@props.project} handler={=>
          React.cloneElement(@props.children, @props)
        } />
      </div>
    </div>

  createNewWorkflow: ->
    @setState creatingWorkflow: true

    workflow = apiClient.type('workflows').create
      display_name: DEFAULT_WORKFLOW_NAME
      primary_language: counterpart.getLocale()
      tasks:
        init:
          type: 'single'
          question: 'Ask your first question here.'
          answers: [
            label: 'Yes'
          ]
      first_task: 'init'
      links:
        project: @props.project.id

    @setState
      workflowCreationError: null
      workflowCreationInProgress: true

    workflow.save()
      .then =>
        @history.pushState(null, "/lab/#{@props.project.id}/workflow/#{workflow.id}")
      .catch (error) =>
        @setState workflowCreationError: error
      .then =>
        @props.project.uncacheLink 'workflows'
        @props.project.uncacheLink 'subject_sets' # An "expert" subject set is automatically created with each workflow.
        if @isMounted()
          @setState workflowCreationInProgress: false

  createNewSubjectSet: ->
    subjectSet = apiClient.type('subject_sets').create
      display_name: DEFAULT_SUBJECT_SET_NAME
      links:
        project: @props.project.id

    @setState
      subjectSetCreationError: null
      subjectSetCreationInProgress: true

    subjectSet.save()
      .then =>
        @history.pushState(null, "/lab/#{@props.project.id}/subject-set/#{subjectSet.id}")
      .catch (error) =>
        @setState subjectSetCreationError: error
      .then =>
        @props.project.uncacheLink 'subject_sets'
        if @isMounted()
          @setState subjectSetCreationInProgress: false

  deleteProject: ->
    @setState deletionError: null

    confirmed = prompt("""
      You are about to delete this project and all its data!
      Enter #{DELETE_CONFIRMATION_PHRASE} to confirm.
    """) is DELETE_CONFIRMATION_PHRASE

    if confirmed
      @setState deletionInProgress: true

      this.props.project.delete()
        .then =>
          @history.pushState(null, "/lab")
        .catch (error) =>
          @setState deletionError: error
        .then =>
          if @isMounted()
            @setState deletionInProgress: false

module.exports = React.createClass
  displayName: 'EditProjectPageWrapper'
  mixins: [TitleMixin, History]
  title: 'Edit'

  componentDidMount: ->
    unless @props.user
      @history.pushState(null, "/lab")

  componentWillReceiveProps: (nextProps) ->
    unless nextProps.user
      @history.pushState(null, "/lab")

  getDefaultProps: ->
    params:
      projectID: '0'

  render: ->
    if @props.user?
      getProject = apiClient.type('projects').get @props.params.projectID

      getOwners = getProject.then (project) =>
        project.get('project_roles', page_size: 100).then (projectRoles) =>
          owners = for projectRole in projectRoles when 'owner' in projectRole.roles or 'collaborator' in projectRole.roles
            projectRole.get 'owner'
          Promise.all owners

      getProjectAndOwners = Promise.all [getProject, getOwners]

      <PromiseRenderer promise={getProjectAndOwners} pending={=>
        <div className="content-container">
          <p className="form-help">Loading project</p>
        </div>
      } then={([project, owners]) =>
        if @props.user in owners
          <EditProjectPage {...@props} project={project} />
        else
          <div className="content-container">
            <p>You don’t have permission to edit this project.</p>
          </div>
      } catch={(error) =>
        <div className="content-container">
          <p className="form-help error">{error.toString()}</p>
        </div>
      } />
    else
      <div className="content-container">
        <p>You need to be signed in to use the lab.</p>
      </div>
