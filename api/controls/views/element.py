from rest_framework.decorators import action
from rest_framework.response import Response

from api.base.views.base import SerializerClasses
from api.base.views.viewsets import ReadOnlyViewSet
from api.controls.serializers.element import DetailedElementSerializer, SimpleElementSerializer, \
    WriteElementTagsSerializer
from api.siteapp.serializers.tags import SimpleTagSerializer
from controls.models import Element


class ElementViewSet(ReadOnlyViewSet):
    queryset = Element.objects.all()
    serializer_classes = SerializerClasses(retrieve=DetailedElementSerializer,
                                           list=SimpleElementSerializer,
                                           set_tags=WriteElementTagsSerializer,
                                           get_tags=SimpleTagSerializer)

    @action(detail=True, url_path="tags", methods=["PUT"])
    def set_tags(self, request, **kwargs):
        element, validated_data = self.validate_serializer_and_get_object(request)
        element.tags.clear()
        element.tags.add(*validated_data['tags'])
        element.save()

        serializer_class = self.get_serializer_class('retrieve')
        serializer = self.get_serializer(serializer_class, element)
        return Response(serializer.data)

    @action(detail=True, url_path="tags", methods=["GET"])
    def get_tags(self, request, **kwargs):
        element = self.get_object()
        serializer_class = self.get_serializer_class()
        serializer = self.get_serializer(serializer_class, element.tags, many=True)
        return Response(serializer.data)