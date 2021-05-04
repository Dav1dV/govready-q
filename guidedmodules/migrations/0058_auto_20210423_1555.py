# Generated by Django 3.1.8 on 2021-04-23 15:55

from django.db import migrations, models
import django.utils.timezone


class Migration(migrations.Migration):

    dependencies = [
        ('guidedmodules', '0057_auto_20210413_1504'),
    ]

    operations = [
        migrations.AddField(
            model_name='instrumentationevent',
            name='created',
            field=models.DateTimeField(auto_now_add=True, db_index=True, default=django.utils.timezone.now),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='instrumentationevent',
            name='updated',
            field=models.DateTimeField(auto_now=True, db_index=True, null=True),
        ),
        migrations.AlterField(
            model_name='appinput',
            name='updated',
            field=models.DateTimeField(auto_now=True, db_index=True, null=True),
        ),
        migrations.AlterField(
            model_name='appsource',
            name='updated',
            field=models.DateTimeField(auto_now=True, db_index=True, null=True),
        ),
        migrations.AlterField(
            model_name='appversion',
            name='updated',
            field=models.DateTimeField(auto_now=True, db_index=True, null=True),
        ),
        migrations.AlterField(
            model_name='module',
            name='updated',
            field=models.DateTimeField(auto_now=True, db_index=True, null=True),
        ),
        migrations.AlterField(
            model_name='moduleasset',
            name='updated',
            field=models.DateTimeField(auto_now=True, db_index=True, null=True),
        ),
        migrations.AlterField(
            model_name='modulequestion',
            name='updated',
            field=models.DateTimeField(auto_now=True, db_index=True, null=True),
        ),
        migrations.AlterField(
            model_name='task',
            name='updated',
            field=models.DateTimeField(auto_now=True, db_index=True, null=True),
        ),
        migrations.AlterField(
            model_name='taskanswer',
            name='updated',
            field=models.DateTimeField(auto_now=True, db_index=True, null=True),
        ),
        migrations.AlterField(
            model_name='taskanswerhistory',
            name='updated',
            field=models.DateTimeField(auto_now=True, db_index=True, null=True),
        ),
    ]