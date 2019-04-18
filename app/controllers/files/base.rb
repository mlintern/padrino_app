# frozen_string_literal: true

# API Base
PadrinoApp::App.controllers :files do
  # Add headers to all api request responses
  # @private
  before do
    headers 'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => %w[OPTIONS GET POST PUT DELETE]
  end

  get :index do
    permission_check('file_upload')
    data = UploadedFile.all(account_id: current_user.id, order: [:name.asc])
    logger.info(data)
    render 'files/list', locals: { 'files' => clean_items(data) }
  end

  # options endpoint
  options :upload do
    return 200
  end

  # file upload endpoint
  get :upload do
    permission_check('file_upload')
    render 'files/index', locals: { 'title' => 'File Upload' }
  end

  # file upload endpoint
  post :upload do
    logger.debug params.inspect

    response_hash = []
    path_base = settings.files_dir + current_user.id + '/'
    create_path_if_not_exist(path_base)
    if params['files'] && !params['files'].empty? && params['files'] != ['']
      files = params['files']
      files.each do |file|
        return 500, { success: false, message: 'File failed to upload' } unless File.file?(file[:tempfile])

        name = file[:filename]
        file_location = path_base + name
        File.rename(file[:tempfile], file_location)
        return 500, { success: false, message: 'File failed to move' } unless File.file?(file_location)

        file = UploadedFile.first(md5sum: Digest::MD5.hexdigest(file_location))
        logger.debug "File Already in Database: #{file.inspect}" unless file.nil?
        file ||= UploadedFile.create(name: name, path: file_location, account_id: current_user.id)
        response_hash << file
      end
    end
    return 200, { success: true, files: response_hash }.to_json
  end

  get :index, with: :id do
    file = UploadedFile.first(id: params['id'])
    return 404 if file.nil?

    send_file file.path
  end

  get :download, map: '/files/:id/download' do
    file = UploadedFile.first(id: params['id'])
    return 404 if file.nil?

    send_file file.path, filename: file.name, type: 'Application/octet-stream'
  end

  # Tasks to run after api call returns
  # @private
  after do
  end
end
