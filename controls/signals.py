# Django Signals configuration
#
#   Receivers/handlers, etc. for
#     automatic SSP OSCAL JSON file export service-side  driven by data model instance changes

from django.db.models.signals import post_save, post_delete
from django.dispatch          import receiver

from django.conf              import settings
import os

import logging
logging.basicConfig()
import structlog
structlog.configure(logger_factory=structlog.stdlib.LoggerFactory())
structlog.configure(processors=[structlog.processors.JSONRenderer()])
logger = structlog.get_logger()

from siteapp.models import Project, User
from .models        import System, Element, ElementControl, Statement


# Automatic SSP OSCAL JSON file export service-side  driven by data model instance changes:
#   - System Project                                    saved
#   - System                      associated w/ Project saved
#   - System.root_element Element associated w/ Project saved
#   - System Control                                    saved or deleted
#   - System Statement                                  saved or deleted

def pause_auto_export():
    """Pause SSP, etc. auto export

        (e.g., before batch operations like assigning a Control baseline)

        See resume_auto_export()
    """
    settings.AUTO_EXPORT_PAUSED = True

def resume_auto_export():
    """Resume SSP, etc. auto export  after pause_auto_export()"""
    settings.AUTO_EXPORT_PAUSED = False


## Register data model instance change signal receivers/handlers

def if_auto_export_not_paused_receiver(*args, **kwargs):
    """Return signal receiver/handler decorator for ignoring signals if auto SSP, etc. export is paused

        See pause_auto_export()
    """
    def decorator(signal_receiver):
        return receiver(*args, **kwargs)(lambda *_args, **_kwargs:
            signal_receiver(*_args, **_kwargs) if not settings.AUTO_EXPORT_PAUSED else None)
    return decorator

export_ssp_if_system_project_saved_signal_uid =           'controls.signals.export_ssp_if_system_project_saved_signal'
@if_auto_export_not_paused_receiver(post_save, sender=Project, dispatch_uid=export_ssp_if_system_project_saved_signal_uid)
def export_ssp_if_system_project_saved_signal(sender, instance, **kwargs):
    """Export SSP if System Project data model instance saved signal"""
    if instance.system:  # System Project
        export_ssp_if_project(instance)

export_ssp_if_system_saved_signal_uid =                  'controls.signals.export_ssp_if_system_saved_signal'
@if_auto_export_not_paused_receiver(post_save, sender=System, dispatch_uid=export_ssp_if_system_saved_signal_uid)
def export_ssp_if_system_saved_signal(sender, instance, **kwargs):
    """Export SSP if Project-associated System data model instance saved signal"""
    export_ssp_if_project(create_project_getter_for_saved_signal(kwargs,
                            lambda: Project.objects.get(system=instance)),
                          'system', instance.id)

def create_project_getter_for_saved_signal(post_save_kwargs, project_getter):
    """Return project_getter()  or  None if Project not found when data model instance created"""
    def get_project():
        try:
            return project_getter()
        except Project.DoesNotExist:
            if not post_save_kwargs['created']:
                raise
    return get_project

export_ssp_if_system_root_element_saved_signal_uid =      'controls.signals.export_ssp_if_system_root_element_saved_signal'
@if_auto_export_not_paused_receiver(post_save, sender=Element, dispatch_uid=export_ssp_if_system_root_element_saved_signal_uid)
def export_ssp_if_system_root_element_saved_signal(sender, instance, **kwargs):
    """Export SSP if Project-associated System.root_element Element data model instance saved signal"""
    export_ssp_if_system_root_element(instance, 'system_root_element', instance.id,
                                      create_project_getter_for_saved_signal(kwargs,
                                        get_system_root_element_project_getter(instance)))

def get_system_root_element_project_getter(system_root_element):
    """Return System.root_element Element's Project getter"""
    return lambda: Project.objects.get(system__root_element=system_root_element)

def export_ssp_if_system_root_element(element, source_type, source_id, project_getter=None):
    """Export SSP if System.root_element Element"""
    if element.element_type == 'system':  # System.root_element Element
        export_ssp_if_project(project_getter if project_getter \
                                else get_system_root_element_project_getter(element),
                              source_type, source_id)

export_ssp_if_system_control_saved_or_deleted_signal_uid =         'controls.signals.export_ssp_if_system_control_saved_or_deleted_signal'
@if_auto_export_not_paused_receiver(post_save,   sender=ElementControl, dispatch_uid=export_ssp_if_system_control_saved_or_deleted_signal_uid)
@if_auto_export_not_paused_receiver(post_delete, sender=ElementControl, dispatch_uid=export_ssp_if_system_control_saved_or_deleted_signal_uid)
def export_ssp_if_system_control_saved_or_deleted_signal(sender, instance, **kwargs):
    """Export SSP if System Control data model instance saved or deleted signal"""
    if instance.element:
        # associated w/ Element  (e.g., System.root_element)
        #   e.g., not just created before association
        export_ssp_if_system_root_element(instance.element, 'system_control', instance.id)
        # e.g., if not Component Control

export_ssp_if_system_statement_saved_or_deleted_signal_uid =  'controls.signals.export_ssp_if_system_statement_saved_or_deleted_signal'
@if_auto_export_not_paused_receiver(post_save,   sender=Statement, dispatch_uid=export_ssp_if_system_statement_saved_or_deleted_signal_uid)
@if_auto_export_not_paused_receiver(post_delete, sender=Statement, dispatch_uid=export_ssp_if_system_statement_saved_or_deleted_signal_uid)
def export_ssp_if_system_statement_saved_or_deleted_signal(sender, instance, **kwargs):
    """Export SSP if System Statement data model instance saved or deleted signal"""
    if instance.consumer_element:
        # associated w/ Element  (e.g., System.root_element)
        #   e.g., not just created before association
        export_ssp_if_system_root_element(instance.consumer_element, 'statement', instance.id)
        # e.g., if not Component/prototype statement


def enable_auto_ssp_export():
    """Enable SSP, etc. auto export  after disable_auto_ssp_export()"""
    if_auto_export_not_paused_receiver(post_save,   sender=Project,        dispatch_uid=export_ssp_if_system_project_saved_signal_uid)(
                                                                                        export_ssp_if_system_project_saved_signal)
    if_auto_export_not_paused_receiver(post_save,   sender=System,         dispatch_uid=export_ssp_if_system_saved_signal_uid)(
                                                                                        export_ssp_if_system_saved_signal)
    if_auto_export_not_paused_receiver(post_save,   sender=Element,        dispatch_uid=export_ssp_if_system_root_element_saved_signal_uid)(
                                                                                        export_ssp_if_system_root_element_saved_signal)
    if_auto_export_not_paused_receiver(post_save,   sender=ElementControl, dispatch_uid=export_ssp_if_system_control_saved_or_deleted_signal_uid)(
                                                                                        export_ssp_if_system_control_saved_or_deleted_signal)
    if_auto_export_not_paused_receiver(post_delete, sender=ElementControl, dispatch_uid=export_ssp_if_system_control_saved_or_deleted_signal_uid)(
                                                                                        export_ssp_if_system_control_saved_or_deleted_signal)
    if_auto_export_not_paused_receiver(post_save,   sender=Statement,      dispatch_uid=export_ssp_if_system_statement_saved_or_deleted_signal_uid)(
                                                                                        export_ssp_if_system_statement_saved_or_deleted_signal)
    if_auto_export_not_paused_receiver(post_delete, sender=Statement,      dispatch_uid=export_ssp_if_system_statement_saved_or_deleted_signal_uid)(
                                                                                        export_ssp_if_system_statement_saved_or_deleted_signal)

def disable_auto_ssp_export():
    """Disable SSP, etc. auto export

        See enable_auto_export()
    """
    post_save.disconnect(  sender=Project,        dispatch_uid=export_ssp_if_system_project_saved_signal_uid)
    post_save.disconnect(  sender=System,         dispatch_uid=export_ssp_if_system_saved_signal_uid)
    post_save.disconnect(  sender=Element,        dispatch_uid=export_ssp_if_system_root_element_saved_signal_uid)
    post_save.disconnect(  sender=ElementControl, dispatch_uid=export_ssp_if_system_control_saved_or_deleted_signal_uid)
    post_delete.disconnect(sender=ElementControl, dispatch_uid=export_ssp_if_system_control_saved_or_deleted_signal_uid)
    post_save.disconnect(  sender=Statement,      dispatch_uid=export_ssp_if_system_statement_saved_or_deleted_signal_uid)
    post_delete.disconnect(sender=Statement,      dispatch_uid=export_ssp_if_system_statement_saved_or_deleted_signal_uid)


def export_ssp_if_project(project_or_getter, other_source_type=None, other_source_id=None):
    """Export the System Project's SSP OSCAL JSON file
        to the service's configured SSP, etc. export destination directory
        for automatic SSP export after changes are made.

        See settings.EXPORT_DIRECTORY

        Parameters:
            project_or_getter (Project|function):  If function, returns Project if found
                                                                        None    if Project legitimately not found
                                                                raises  Project.DoesNotExist otherwise

            other_source_type (str):               Non-Project source type name for error logging
            other_source_id   (str):               Non-Project source id        for error logging
    """

    project  = None
    user     = None
    filepath = None
    def log_event(error_name=None, exception=None):

        log   = logger.info
        event = 'auto_export_ssp'
        if error_name:
            log   = logger.error
            event = f'{event} {error_name}'

        object = {}
        if project:
            object['object']    = 'system'
            object['id']        = project.system.id
        else:
            object['object']    = other_source_type
            object['id']        = other_source_id
        if filepath:
            object['file_path'] = filepath
        if exception:
            object['error']     = exception

        kwargs = {
            'event':  event,
            'object': object,
        }
        if user:
            kwargs['user'] = {
                'id':       user.id,
                'username': user.username
            }

        log(**kwargs)

    try:
        project = project_or_getter if isinstance(project_or_getter, Project) \
                    else project_or_getter()
        if project:
            # Get or create SSP Task as User 1
            user = User.objects.get(pk=1)  # 1st/anonymous user
            task = project.root_task.get_or_create_subtask(user, 'ssp_intro')

            # Generate SSP file to directory
            answers = task.get_answers().with_extended_info()
            try:
                # Render SSP
                bytes, filename, mime_type = task.download_output_document('ssp_v1_oscal_json',
                                                                           'json', answers)
            except Exception as e:
                log_event('document_render_failed', e)
            else:
                # Write SSP as file to directory
                os.makedirs(settings.EXPORT_DIRECTORY, exist_ok=True)
                filepath = os.path.join(settings.EXPORT_DIRECTORY,
                                        f'{project.system.get_name()}-{filename}')
                                        # e.g., 'My App-ssp_v1_oscal_json.json'
                file = open(filepath, 'wb')
                file.write(bytes)
                file.close()

                log_event()

    except Project.DoesNotExist as e:
        log_event('project_not_found', e)

    except User.DoesNotExist as e:
        log_event('user_not_found', e)

    except OSError as e:
        log_event('file_write_failed', e)

    except Exception as e:
        log_event('failed', e)
